//
//  StockServiceProvider.swift
//  Q_stockReader
//
//  Created by Philippe Blanchette on 2025-04-29.
//

import Foundation


/*
 Provider
*/

class StockServiceProvider: ObservableObject {
    typealias Service = StockService
    
    func resolve() -> StockService {
        StockService(
            historicalRepository: RemoteStockRepository(withEndpoint: .historic),
            currentRepository: RemoteStockRepository(withEndpoint: .current)
        )
    }
}

class StockServiceProviderMock: ObservableObject {
    typealias Service = StockService
    
    func resolve() -> StockService {
        StockService(
            historicalRepository: MockStockRepository(),
            currentRepository: MockStockRepository()
        )
    }
}
