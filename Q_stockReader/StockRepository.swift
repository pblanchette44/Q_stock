//
//  StockRepository.swift
//  Q_stockReader
//
//  Created by Philippe Blanchette on 2025-04-29.
//

import Foundation

/*
    Repository pattern, includes the DTO for the various json,
    currently there's only one mock and DTO, because both jsons are the same format,
    but you can change them with wtv dto you see fit if they change
*/

protocol StockRepository {
    func fetchStocks() async throws -> StockResultsDTO
}

protocol RemoteRepository {
    func fetchData<T>(forRequest request: URLRequest) async throws -> T where T: Decodable
}

enum RepositoryError: Error {
    case invalidResponseError
    case networkError
    case decodingError
    case taskIsCancelled
}

/*
    Generic data fetching function that is available to any adopter of the RemoteRepository protocol
*/

extension RemoteRepository {
    
    func fetchData<T>(forRequest request: URLRequest) async throws -> T where T: Decodable {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw RepositoryError.invalidResponseError
        }
        
        switch response.statusCode {
        case 200...299:
            do {
                let stocks: T = try JSONDecoder().decode(T.self, from: data)
                return stocks
            } catch {
                throw RepositoryError.decodingError
            }
        default:
            throw RepositoryError.networkError
        }
    }
}

struct StockDTO: Decodable {
    var name: String
    var ticker: String
    var current_price: Double
    var id: Int
}

struct StockResultsDTO: Decodable {
    var stocks: [StockDTO]
}

class MockStockRepository: StockRepository {

    func fetchStocks() async throws -> StockResultsDTO {
        .init(stocks: [
            .init(name: "Wolf, Conroy and Dickinson", ticker: "LHCL", current_price: 5.39, id: 1),
            .init(name: "Bogisich Group", ticker: "DMJH", current_price: 25.24, id: 2),
            .init(name: "Schmitt-Kuphal", ticker: "ZJEO", current_price: 7.61, id: 3)
        ])
    }
}

class RemoteStockRepository: StockRepository, RemoteRepository {
    
    enum StockEndpoint {
        case historic
        case current
        
        private var baseUrl: String {
            "https://gist.githubusercontent.com/rockarts/07e1f458e79ba521a7e62aec6b231479/raw/75484217fab58cd86876ae0bc910bc61020978f5"
        }
        
        private var endpoint: String {
            switch self {
            case .historic:
                "/historical.json"
            case .current:
                "/current.json"
            }
        }
        
        var request: URLRequest {
            let urlString = URL(string: baseUrl + endpoint)!
            
            return URLRequest(url: urlString)
        }
    }
    var endpoint: StockEndpoint
    
    var fetchingTask: Task<StockResultsDTO, any Error>?
    
    init(withEndpoint endpoint: StockEndpoint) {
        self.endpoint = endpoint
    }

    func fetchStocks() async throws -> StockResultsDTO {
        
        fetchingTask?.cancel()
        
        fetchingTask = Task {
            do {
                let dto: StockResultsDTO = try await fetchData(forRequest: self.endpoint.request)
                return dto
            } catch {
                if Task.isCancelled {
                    throw RepositoryError.taskIsCancelled
                }
                throw error
            }
        }
        
        return try await fetchingTask!.value
    }
}
