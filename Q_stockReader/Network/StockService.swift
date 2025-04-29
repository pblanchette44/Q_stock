//
//  StockService.swift
//  Q_stockReader
//
//  Created by Philippe Blanchette on 2025-04-29.
//

import Foundation

/*
    The Stock service, which perform the list heavy lifting, filtering and mapping of the two data sources
    
 I didn't get to a caching system:
        partly because at first I wanted to cache at the repository level,
        but since the remote api doesn't take parameter and we fetch the whole json every call,
        It would have amounted to storing the whole db which I didn't like.
 
        we could cache results here at the service level, associating a key with a set of results,
        but that wouldn't limit our network calls.
*/

protocol StockFetchingService {
    func fetchStock(forKey key: String) async throws -> [Stock]
}

struct Stock: Identifiable {
    let name: String
    let ticker: String
    let currentPrice: Double
    let averagePrice: Double
    let id: Int
}

enum StockServiceError: Error {
    case noResultsError
}

class StockService: StockFetchingService {
    
    var historicalRepository: any StockRepository
    var currentRepository: any StockRepository
    
    init(
        historicalRepository: any StockRepository,
        currentRepository: any StockRepository
    ) {
        self.historicalRepository = historicalRepository
        self.currentRepository = currentRepository
    }
    
    func fetchStock(forKey key: String) async throws -> [Stock] {
        let historicalResults = try await self.fetchStock(forKey: key, repository: historicalRepository)
        let currentResults = try await self.fetchStock(forKey: key, repository: currentRepository)
        
        let stockList: [Stock] = historicalResults.compactMap {
            guard let currentValue = currentResults[$0.key] else {
                return nil
            }
            
            return Stock.init(
                name: $0.value.name,
                ticker: $0.value.ticker,
                currentPrice: currentValue.current_price,
                averagePrice: (currentValue.current_price + $0.value.current_price),
                id: $0.value.id
            )
        }
        
        guard !stockList.isEmpty else {
            throw StockServiceError.noResultsError
        }
        
        return stockList
    }
    
    // this is the function we would be caching in a future update.
    private func fetchStock<Repo>(
        forKey key: String,
        repository: Repo
    ) async throws -> Dictionary<Int, StockDTO> where Repo: StockRepository {
        let array = try await repository.fetchStocks()
            .stocks
            .filter {
                $0.name.lowercased().contains(key.lowercased()) || $0.ticker.lowercased().contains(key.lowercased())
            }
            .map {
                (
                    $0.id,
                    $0
                )
            }
        
        return Dictionary(uniqueKeysWithValues: array)
    }
}
