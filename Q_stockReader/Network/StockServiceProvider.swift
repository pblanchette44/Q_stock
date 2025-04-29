//
//  StockServiceProvider.swift
//  Q_stockReader
//
//  Created by Philippe Blanchette on 2025-04-29.
//

import Foundation

/*
    Service provider:
    I didn't get around to write some tests for this app,
    but I get the impression we could easily just switch the provider for the mock one I used during early development to provide test data.
*/

protocol Provider: ObservableObject {
    func resolve() -> StockService
}

class StockServiceProvider: Provider, ObservableObject {
    func resolve() -> StockService {
        StockService(
            historicalRepository: RemoteStockRepository(withEndpoint: .historic),
            currentRepository: RemoteStockRepository(withEndpoint: .current)
        )
    }
}

class StockServiceProviderMock: Provider, ObservableObject {
    func resolve() -> StockService {
        StockService(
            historicalRepository: MockStockRepository(),
            currentRepository: MockStockRepository()
        )
    }
}
