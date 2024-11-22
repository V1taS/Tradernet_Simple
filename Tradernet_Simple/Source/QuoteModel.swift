//
//  QuoteModel.swift
//  Tradernet_Simple
//
//  Created by Vitalii Sosin on 22.11.2024.
//

import Foundation

/// Этот файл содержит реализацию структуры данных для котировок.
///
/// - `QuoteModel`: Публичная структура данных, используемая для хранения информации о финансовых инструментах и их котировках.
/// - `QuoteModel.Ticker`: Перечисление доступных тикеров, используемое для указания инструментов для получения котировок.

/// Публичная структура данных котировки
public struct QuoteModel: Hashable {
  /// Тикер
  public let ticker: String
  /// Цена последней сделки
  public var lastPrice: Double
  /// Изменение цены последней сделки в пунктах относительно цены закрытия предыдущей торговой сессии
  public var changeInPoints: Double
  /// Изменение в процентах относительно цены закрытия предыдущей торговой сессии
  public var changeInPercent: Double
  /// Биржа последней сделки
  public let lastTradeExchange: String?
  /// Название бумаги
  public let name: String?
  /// Время последней сделки
  public let lastTradeTime: String?
  /// Минимальный шаг цены
  public var minStep: Double
  
  /// Публичный инициализатор для структуры `QuoteData`
  /// - Parameters:
  ///   - ticker: Тикер
  ///   - lastPrice: Цена последней сделки
  ///   - changeInPoints: Изменение цены в пунктах
  ///   - changeInPercent: Изменение в процентах
  ///   - minStep: Минимальный шаг цены
  ///   - lastTradeExchange: Биржа последней сделки
  ///   - name: Название бумаги
  ///   - lastTradeTime: Время последней сделки
  public init(
    ticker: String,
    lastPrice: Double,
    changeInPoints: Double,
    changeInPercent: Double,
    minStep: Double,
    lastTradeExchange: String? = nil,
    name: String? = nil,
    lastTradeTime: String? = nil
  ) {
    self.ticker = ticker
    self.lastPrice = lastPrice
    self.changeInPoints = changeInPoints
    self.changeInPercent = changeInPercent
    self.minStep = minStep
    self.lastTradeExchange = lastTradeExchange
    self.name = name
    self.lastTradeTime = lastTradeTime
  }
}
