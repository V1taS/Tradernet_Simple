//
//  ViewController.swift
//  Tradernet_Simple
//
//  Created by Vitalii Sosin on 22.11.2024.
//

import UIKit
import SnapKit

final class MainScreenViewController: UIViewController {
  
  // MARK: - Private properties
  
  private let tableView = UITableView()
  private var quoteModels: [QuoteModel] = []
  private var quoteCache: [String: QuoteCacheItem] = [:]
  private let quoteService = QuoteService()
  private let activityIndicator = UIActivityIndicatorView()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    setupActivityIndicator()
    activityIndicator.startAnimating()
    
    quoteService.fetchTicker(
      type: Constants.quoteType,
      exchange: Constants.quoteExchange,
      gainers: .zero,
      limit: Constants.quoteLimit
    ) { [weak self] result in
      DispatchQueue.main.async {
        self?.activityIndicator.stopAnimating()
      }
      switch result {
      case let .success(tickers):
        self?.startQuoteService(tickers: tickers)
      case let .failure(error):
        print(Constants.errorFetchingQuotes + error.localizedDescription)
      }
    }
  }
}

// MARK: - UITableViewDataSource

extension MainScreenViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return quoteModels.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: Constants.cellIdentifier,
      for: indexPath
    ) as? QuoteCard.Cell else {
      return UITableViewCell()
    }
    
    configureCell(cell, at: indexPath)
    return cell
  }
}

// MARK: - UITableViewDelegate

extension MainScreenViewController: UITableViewDelegate {}

// MARK: - QuoteCacheItem

private extension MainScreenViewController {
  final class QuoteCacheItem {
    var quoteModel: QuoteModel
    var timer: Timer?
    var style: QuoteCard.Style
    var image: UIImage?
    
    init(quoteModel: QuoteModel, style: QuoteCard.Style) {
      self.quoteModel = quoteModel
      self.style = style
    }
  }
}

// MARK: - Private

private extension MainScreenViewController {
  func setupTableView() {
    view.addSubview(tableView)
    tableView.register(QuoteCard.Cell.self, forCellReuseIdentifier: Constants.cellIdentifier)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.estimatedRowHeight = UITableView.automaticDimension
    tableView.rowHeight = Constants.rowHeight
    
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  func setupActivityIndicator() {
    view.addSubview(activityIndicator)
    activityIndicator.hidesWhenStopped = true
    
    activityIndicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  func startQuoteService(tickers: [String]) {
    quoteService.connectToWebSocket(tickers: tickers) { [weak self] newQuoteModel in
      guard let self = self else { return }
      let ticker = newQuoteModel.ticker
      
      if let cacheItem = self.quoteCache[ticker] {
        self.updateExistingQuoteModel(newQuoteModel, cacheItem: cacheItem)
      } else {
        self.addNewQuoteModel(newQuoteModel)
      }
    } onError: { error in
      print(Constants.errorFetchingQuotes + error.localizedDescription)
    }
  }
  
  func updateExistingQuoteModel(_ newQuoteModel: QuoteModel, cacheItem: QuoteCacheItem) {
    let ticker = newQuoteModel.ticker
    let oldChangeInPercent = cacheItem.quoteModel.changeInPercent
    let newChangeInPercent = newQuoteModel.changeInPercent
    
    cacheItem.quoteModel.lastPrice = newQuoteModel.lastPrice
    cacheItem.quoteModel.changeInPoints = newQuoteModel.changeInPoints
    cacheItem.quoteModel.changeInPercent = newQuoteModel.changeInPercent
    
    if newChangeInPercent > oldChangeInPercent {
      startBubbleTimer(for: cacheItem, positive: true)
    } else if newChangeInPercent < oldChangeInPercent {
      startBubbleTimer(for: cacheItem, positive: false)
    } else {
      cacheItem.style = determineStyle(for: cacheItem.quoteModel)
      updateUI(for: ticker)
    }
  }
  
  func addNewQuoteModel(_ newQuoteModel: QuoteModel) {
    let ticker = newQuoteModel.ticker
    let style = determineStyle(for: newQuoteModel)
    let cacheItem = QuoteCacheItem(quoteModel: newQuoteModel, style: style)
    self.quoteCache[ticker] = cacheItem
    
    DispatchQueue.main.async {
      self.tableView.beginUpdates()
      let newIndexPath = IndexPath(row: self.quoteModels.count, section: .zero)
      self.quoteModels.append(newQuoteModel)
      self.tableView.insertRows(at: [newIndexPath], with: .automatic)
      self.tableView.endUpdates()
    }
    
    self.quoteService.downloadLogo(ticker: ticker) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case let .success(imageData):
        if let downloadedImage = UIImage(data: imageData) {
          cacheItem.image = downloadedImage
          self.updateUI(for: ticker)
        }
      case .failure:
        break
      }
    }
  }
  
  func startBubbleTimer(for cacheItem: QuoteCacheItem, positive: Bool) {
    let ticker = cacheItem.quoteModel.ticker
    cacheItem.style = positive ? .positiveWithBubble : .negativeWithBubble
    updateUI(for: ticker)
    
    cacheItem.timer?.invalidate()
    cacheItem.timer = Timer.scheduledTimer(withTimeInterval: Constants.bubbleTimerInterval, repeats: false) { [weak self, weak cacheItem] _ in
      guard let self = self, let cacheItem = cacheItem else { return }
      cacheItem.style = positive ? .positive : .negative
      self.updateUI(for: ticker)
    }
  }
  
  func determineStyle(for quoteModel: QuoteModel) -> QuoteCard.Style {
    if quoteModel.changeInPercent > .zero {
      return .positive
    } else if quoteModel.changeInPercent < .zero {
      return .negative
    } else {
      return .standard
    }
  }
  
  func roundToMinStep(value: Double, minStep: Double) -> Double {
    let steps = round(value / minStep)
    return steps * minStep
  }
  
  func updateUI(for ticker: String) {
    if let index = self.quoteModels.firstIndex(where: { $0.ticker == ticker }) {
      DispatchQueue.main.async {
        if index < self.quoteModels.count {
          self.tableView.reloadRows(at: [IndexPath(row: index, section: .zero)], with: .automatic)
        }
      }
    }
  }
  
  func configureCell(_ cell: QuoteCard.Cell, at indexPath: IndexPath) {
    let quoteModel = quoteModels[indexPath.row]
    let ticker = quoteModel.ticker
    
    let style: QuoteCard.Style
    let image: UIImage?
    if let cacheItem = quoteCache[ticker] {
      style = cacheItem.style
      image = cacheItem.image
    } else {
      style = determineStyle(for: quoteModel)
      image = nil
    }
    
    let formattedChangeInPoints: String
    if quoteModel.changeInPoints > .zero {
      formattedChangeInPoints = Constants.positiveSign + "\(quoteModel.changeInPoints)"
    } else {
      formattedChangeInPoints = "\(quoteModel.changeInPoints)"
    }
    
    let roundedLastPrice = roundToMinStep(value: quoteModel.lastPrice, minStep: quoteModel.minStep)
    
    cell.configure(
      leftSideImage: image ?? UIImage(named: Constants.placeholderImageName),
      leftSideTitle: quoteModel.ticker,
      leftSideDescription: quoteModel.name ?? "",
      rightSideTitle: "\(quoteModel.changeInPercent) \(Constants.percentSymbol)",
      rightSideTitleStyle: style,
      rightSideDescription: "\(String(format: Constants.priceFormat, roundedLastPrice)) (\(formattedChangeInPoints))"
    )
    
    if image == nil {
      quoteService.downloadLogo(ticker: ticker) { [weak self] result in
        guard let self = self else { return }
        switch result {
        case let .success(imageData):
          if let downloadedImage = UIImage(data: imageData) {
            if let cacheItem = self.quoteCache[ticker] {
              cacheItem.image = downloadedImage
              DispatchQueue.main.async {
                if let visibleIndexPaths = self.tableView.indexPathsForVisibleRows,
                   visibleIndexPaths.contains(indexPath) {
                  self.tableView.reloadRows(at: [indexPath], with: .none)
                }
              }
            }
          }
        case .failure:
          break
        }
      }
    }
  }
}

// MARK: - Constants

private enum Constants {
  static let rowHeight: CGFloat = 68
  static let quoteType = "stocks"
  static let quoteExchange = "russia"
  static let quoteLimit = 30
  static let cellIdentifier = "QuoteCardCell"
  static let placeholderImageName = "placeholder"
  static let bubbleTimerInterval = 2.0
  static let positiveSign = "+"
  static let percentSymbol = "%"
  static let priceFormat = "%.2f"
  static let errorFetchingQuotes = "Ошибка при получении котировок: "
}
