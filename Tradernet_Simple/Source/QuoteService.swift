//
//  QuoteService.swift
//  Tradernet_Simple
//
//  Created by Vitalii Sosin on 22.11.2024.
//

import Foundation
import Starscream

/// Сервис для получения котировок
public final class QuoteService: WebSocketDelegate {
  public init() {}
  
  // MARK: - Private properties
  
  private var socket: WebSocket!
  private var onDataReceived: ((QuoteModel) -> Void)?
  private var onError: ((Error) -> Void)?
  private var isConnected = false
  private var tickers: [String] = []
  
  // MARK: - Public funcs
  
  /// Запуск подключения к WebSocket и получение котировок
  /// - Parameters:
  ///   - tickers: Список тикеров, которые необходимо отслеживать
  ///   - onDataReceived: Замыкание, вызываемое при получении данных
  ///   - onError: Замыкание, вызываемое при возникновении ошибки
  public func connectToWebSocket(
    tickers: [String],
    onDataReceived: @escaping (QuoteModel) -> Void,
    onError: @escaping (Error) -> Void
  ) {
    self.tickers = tickers
    self.onDataReceived = onDataReceived
    self.onError = onError
    
    guard let url = URL(string: "wss://wss.tradernet.com") else {
      let error = NSError(domain: "QuoteService", code: .zero, userInfo: [
        NSLocalizedDescriptionKey: "Недопустимый URL"
      ])
      onError(error)
      return
    }
    
    let request = URLRequest(url: url)
    socket = WebSocket(request: request)
    socket.delegate = self
    socket.connect()
  }
  
  public func stop() {
    socket.disconnect()
    isConnected = false
  }
  
  /// Метод для скачивания изображения по тикеру
  /// - Parameters:
  ///   - ticker: Тикер, для которого нужно скачать изображение
  ///   - completion: Замыкание с результатом: либо UIImage, либо ошибка
  public func downloadLogo(
    ticker: String,
    completion: @escaping (Result<Data, Error>) -> Void
  ) {
    let urlString = "https://tradernet.com/logos/get-logo-by-ticker?ticker=\(ticker.lowercased())"
    guard let url = URL(string: urlString) else {
      let error = NSError(domain: "QuoteService", code: .zero, userInfo: [
        NSLocalizedDescriptionKey: "Недопустимый URL"]
      )
      completion(.failure(error))
      return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      if let error = error {
        completion(.failure(error))
        return
      }
      
      guard let data else {
        let error = NSError(domain: "QuoteService", code: .zero, userInfo: [
          NSLocalizedDescriptionKey: "Не удалось получить изображение"]
        )
        completion(.failure(error))
        return
      }
      
      completion(.success(data))
    }
    task.resume()
  }
  
  /// Метод для получения списка котировок
  /// - Parameters:
  ///   - type: Тип инструмента
  ///   - exchange: Биржа
  ///   - gainers: Тип списка (1 - самые быстрорастущие, 0 - по объему торгов)
  ///   - limit: Количество отображаемых инструментов
  ///   - completion: Замыкание с результатом: либо список тикеров, либо ошибка
  public func fetchTicker(
    type: String,
    exchange: String,
    gainers: Int,
    limit: Int,
    completion: @escaping (Result<[String], Error>) -> Void
  ) {
    let url = URL(string: "https://tradernet.com/api/")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let params: [String: Any] = [
      "cmd": "getTopSecurities",
      "params": [
        "type": type,
        "exchange": exchange,
        "gainers": gainers,
        "limit": limit
      ]
    ]
    
    do {
      // Сериализуем параметры в JSON-строку
      let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
      guard let jsonString = String(data: jsonData, encoding: .utf8) else {
        let error = NSError(domain: "QuoteService", code: .zero, userInfo: [
          NSLocalizedDescriptionKey: "Ошибка при преобразовании данных в строку"
        ])
        completion(.failure(error))
        return
      }
      
      // Кодируем JSON-строку для использования в URL
      guard let encodedJSONString = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
        let error = NSError(domain: "QuoteService", code: .zero, userInfo: [
          NSLocalizedDescriptionKey: "Ошибка при кодировании строки"
        ])
        completion(.failure(error))
        return
      }
      
      // Формируем тело запроса
      let postString = "q=\(encodedJSONString)"
      request.httpBody = postString.data(using: .utf8)
      request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    } catch {
      completion(.failure(error))
      return
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        completion(.failure(error))
        return
      }
      
      guard let data = data else {
        let error = NSError(domain: "QuoteService", code: .zero, userInfo: [NSLocalizedDescriptionKey: "Нет данных"])
        completion(.failure(error))
        return
      }
      
      do {
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let tickers = json["tickers"] as? [String] {
          completion(.success(tickers))
        } else if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let errorCode = json["code"] as? Int,
                  let errorMessage = json["error"] as? String {
          let error = NSError(domain: "QuoteService", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
          completion(.failure(error))
        } else {
          let error = NSError(domain: "QuoteService", code: .zero, userInfo: [NSLocalizedDescriptionKey: "Некорректный формат ответа"])
          completion(.failure(error))
        }
      } catch {
        completion(.failure(error))
      }
    }
    
    task.resume()
  }
  
  
  // MARK: - WebSocketDelegate методы
  
  public func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
    switch event {
    case .connected:
      isConnected = true
      subscribeToQuotes()
    case .disconnected:
      isConnected = false
    case .text(let text):
      handleMessage(text)
    case .binary(_):
      break
    case let .error(error):
      isConnected = false
      if let error = error {
        onError?(error)
      }
    case .cancelled:
      isConnected = false
    default:
      break
    }
  }
}

// MARK: - Private

private extension QuoteService {
  func handleMessage(_ text: String) {
    guard let data = text.data(using: .utf8) else {
      return
    }
    guard let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any] else {
      return
    }
    guard jsonArray.count >= 2 else {
      return
    }
    guard let event = jsonArray[0] as? String,
          let payload = jsonArray[1] as? [String: Any],
          event == "q" else {
      return
    }
    
    guard let ticker = payload["c"] as? String,
          let lastPrice = payload["ltp"] as? Double,
          let changeInPoints = payload["chg"] as? Double,
          let changeInPercent = payload["pcp"] as? Double else {
      return
    }
    
    let minStep = payload["min_step"] as? Double ?? .zero
    let lastTradeExchange = payload["ltr"] as? String
    let name = payload["name"] as? String
    let lastTradeTime = payload["ltt"] as? String
    
    let quoteModel = QuoteModel(
      ticker: ticker,
      lastPrice: lastPrice,
      changeInPoints: changeInPoints,
      changeInPercent: changeInPercent,
      minStep: minStep,
      lastTradeExchange: lastTradeExchange,
      name: name,
      lastTradeTime: lastTradeTime
    )
    
    onDataReceived?(quoteModel)
  }
  
  func subscribeToQuotes() {
    let subscription: [Any] = ["realtimeQuotes", tickers]
    if let data = try? JSONSerialization.data(withJSONObject: subscription, options: []),
       let jsonString = String(data: data, encoding: .utf8) {
      socket.write(string: jsonString)
    }
  }
}
