//
//  QuoteCardCell.swift
//  Tradernet_Simple
//
//  Created by Vitalii Sosin on 22.11.2024.
//

import UIKit

/// Этот файл содержит реализацию компонентов для отображения карточек котировок.
///
/// - `QuoteCard`: Перечисление, служащее пространством имен для связанных классов и структур.
/// - `QuoteCard.Cell`: Ячейка таблицы для отображения котировки с настраиваемыми элементами.
/// - `QuoteCard.LabelGradientView`: Вид с градиентным фоном и текстовым лейблом.
/// - `QuoteCard.Style`: Перечисление, определяющее различные стили отображения котировок.

/// `QuoteCard` - Пространством имен для отображения котировок
public enum QuoteCard {}

// MARK: - Cell

/// Ячейка для отображения котировок
extension QuoteCard {
  public final class Cell: UITableViewCell {
    
    // MARK: - Private properties
    
    private let mainHorizontalStackView: UIStackView = {
      let stackView = UIStackView()
      stackView.axis = .horizontal
      stackView.spacing = 8
      return stackView
    }()
    
    private let mainVerticalStackView: UIStackView = {
      let stackView = UIStackView()
      stackView.axis = .vertical
      stackView.spacing = 4
      return stackView
    }()
    
    private let firstLineHorizontalStackView: UIStackView = {
      let stackView = UIStackView()
      stackView.axis = .horizontal
      stackView.alignment = .center
      return stackView
    }()
    
    private let secondLineHorizontalStackView: UIStackView = {
      let stackView = UIStackView()
      stackView.axis = .horizontal
      stackView.alignment = .center
      return stackView
    }()
    
    private let rightSideImageView: UIImageView = {
      let imageView = UIImageView()
      imageView.contentMode = .scaleAspectFit
      imageView.image = UIImage(named: "chevron-right")?.withRenderingMode(.alwaysTemplate)
      imageView.tintColor = #colorLiteral(red: 0.7647058964, green: 0.764705956, blue: 0.7647058964, alpha: 1)
      NSLayoutConstraint.activate([
        imageView.widthAnchor.constraint(equalToConstant: 16),
        imageView.heightAnchor.constraint(equalToConstant: 16)
      ])
      return imageView
    }()
    
    private let leftSideImageView: UIImageView = {
      let imageView = UIImageView()
      imageView.contentMode = .scaleAspectFit
      NSLayoutConstraint.activate([
        imageView.widthAnchor.constraint(equalToConstant: 24),
        imageView.heightAnchor.constraint(equalToConstant: 24)
      ])
      return imageView
    }()
    
    private let leftSideTitleLabel: UILabel = {
      let label = UILabel()
      label.font = .systemFont(ofSize: 17, weight: .medium)
      label.textColor = .black
      return label
    }()
    
    private let rightSideTitleLabel = LabelGradientView()
    
    private let leftSideDescriptionLabel: UILabel = {
      let label = UILabel()
      label.font = .systemFont(ofSize: 15, weight: .regular)
      label.textColor = .systemGray
      return label
    }()
    
    private let rightSideDescriptionLabel: UILabel = {
      let label = UILabel()
      label.font = .systemFont(ofSize: 15, weight: .regular)
      label.textColor = .black
      return label
    }()
    
    // MARK: - Initialisation
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      configureLayout()
      applyDefaultBehavior()
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public funcs
    
    /// Конфигурация ячейки `QuoteCard`.
    /// - Parameters:
    ///   - leftSideImage: Изображение слева.
    ///   - leftSideTitle: Заголовок слева.
    ///   - leftSideDescription: Описание слева.
    ///   - rightSideTitle: Заголовок справа.
    ///   - rightSideTitleStyle: Стиль заголовка справа.
    ///   - rightSideDescription: Описание справа.
    public func configure(
      leftSideImage: UIImage?,
      leftSideTitle: String,
      leftSideDescription: String,
      rightSideTitle: String,
      rightSideTitleStyle: QuoteCard.Style,
      rightSideDescription: String
    ) {
      leftSideImageView.image = leftSideImage
      leftSideImageView.isHidden = leftSideImage == nil
      
      leftSideTitleLabel.text = leftSideTitle
      leftSideDescriptionLabel.text = leftSideDescription
      rightSideDescriptionLabel.text = rightSideDescription
      
      rightSideTitleLabel.configureWith(
        titleText: rightSideTitle,
        font: .systemFont(ofSize: 17, weight: .medium),
        textColor: rightSideTitleStyle.textColor,
        gradientColors: rightSideTitleStyle.backgroundBubbleColor
      )
    }
    
    // MARK: - Private
    
    private func configureLayout() {
      contentView.addSubview(mainHorizontalStackView)
      mainHorizontalStackView.translatesAutoresizingMaskIntoConstraints = false
      
      mainVerticalStackView.addArrangedSubview(firstLineHorizontalStackView)
      mainVerticalStackView.addArrangedSubview(secondLineHorizontalStackView)
      
      mainHorizontalStackView.addArrangedSubview(mainVerticalStackView)
      mainHorizontalStackView.addArrangedSubview(rightSideImageView)
      
      firstLineHorizontalStackView.addArrangedSubview(leftSideImageView)
      firstLineHorizontalStackView.addArrangedSubview(leftSideTitleLabel)
      firstLineHorizontalStackView.addArrangedSubview(UIView())
      firstLineHorizontalStackView.addArrangedSubview(rightSideTitleLabel)
      
      secondLineHorizontalStackView.addArrangedSubview(leftSideDescriptionLabel)
      secondLineHorizontalStackView.addArrangedSubview(UIView())
      secondLineHorizontalStackView.addArrangedSubview(rightSideDescriptionLabel)
      
      NSLayoutConstraint.activate([
        mainHorizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        mainHorizontalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
        mainHorizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        mainHorizontalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        contentView.heightAnchor.constraint(equalToConstant: 68)
      ])
    }
    
    private func applyDefaultBehavior() {
      backgroundColor = .white
      selectionStyle = .none
      firstLineHorizontalStackView.setCustomSpacing(4, after: leftSideImageView)
    }
  }
}

// MARK: - LabelGradientView

extension QuoteCard {
  public final class LabelGradientView: UIView {
    
    // MARK: - Private properties
    
    private let titleLabel = UILabel()
    private let cornerRadius: CGFloat = 6
    private let contentInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
    
    // MARK: - Initialization
    
    override public class var layerClass: AnyClass {
      return CAGradientLayer.self
    }
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      configureLayout()
      applyDefaultBehavior()
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public func
    
    /// Настройка градиентного лейбла
    /// - Parameters:
    ///  - titleText: Текст заголовка
    ///  - font: Шрифт
    ///  - textColor: Цвет текста
    ///  - borderWidth: Ширина границы
    ///  - borderColor: Цвет границы
    ///  - gradientColors: Цвета градиента
    public func configureWith(
      titleText: String?,
      font: UIFont? = nil,
      textColor: UIColor? = nil,
      borderWidth: CGFloat? = nil,
      borderColor: UIColor? = nil,
      gradientColors: [UIColor]
    ) {
      titleLabel.text = titleText
      applyGradient(colors: gradientColors)
      
      if let font = font {
        titleLabel.font = font
      }
      
      if let textColor = textColor {
        titleLabel.textColor = textColor
      }
      
      if let borderWidth = borderWidth {
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor?.cgColor
      }
    }
    
    // MARK: - Private func
    
    private func configureLayout() {
      addSubview(titleLabel)
      titleLabel.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInsets.left),
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: contentInsets.top),
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInsets.right),
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentInsets.bottom)
      ])
    }
    
    private func applyDefaultBehavior() {
      layer.cornerRadius = cornerRadius
    }
    
    private func applyGradient(colors: [UIColor]) {
      guard let gradientLayer = layer as? CAGradientLayer else { return }
      gradientLayer.colors = colors.map { $0.cgColor }
    }
  }
}

// MARK: - Style

extension QuoteCard {
  public enum Style {
    case standard
    case positive
    case negative
    case positiveWithBubble
    case negativeWithBubble
    
    var isBubble: Bool {
      switch self {
      case .positiveWithBubble, .negativeWithBubble:
        return true
      default:
        return false
      }
    }
    
    /// Цвет фона пузырька
    public var backgroundBubbleColor: [UIColor] {
      switch self {
      case .positive, .negative, .standard:
        return [.clear]
      case .positiveWithBubble:
        return [#colorLiteral(red: 0.4486071467, green: 0.7447194457, blue: 0.2674421668, alpha: 1), #colorLiteral(red: 0.4486071467, green: 0.7447194457, blue: 0.2674421668, alpha: 1)]
      case .negativeWithBubble:
        return [#colorLiteral(red: 0.989157021, green: 0.1765886247, blue: 0.3534493446, alpha: 1), #colorLiteral(red: 0.989157021, green: 0.1765886247, blue: 0.3534493446, alpha: 1)]
      }
    }
    
    /// Цвет котировок
    public var textColor: UIColor? {
      switch self {
      case .positive:
        return #colorLiteral(red: 0.4486071467, green: 0.7447194457, blue: 0.2674421668, alpha: 1)
      case .negative:
        return #colorLiteral(red: 0.989157021, green: 0.1765886247, blue: 0.3534493446, alpha: 1)
      case .positiveWithBubble, .negativeWithBubble:
        return .white
      case .standard:
        return .black
      }
    }
  }
}
