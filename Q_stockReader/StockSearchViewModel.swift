//
//  StockSearchViewModel.swift
//  Q_stockReader
//
//  Created by Philippe Blanchette on 2025-04-29.
//

import Foundation

enum PageState {
    case initial
    case empty
    case error
    case results
    case loading
}

class StockViewModel: SearchBarManager {
    
    // This has been put lazy If we ever want to put some logic to return some different services based off some runtime conditions like network state
    private lazy var stockService: any StockFetchingService = {
        provider.resolve()
    }()
    
    private let provider: StockServiceProvider
    
    @Published var pageState: PageState = .initial
    
    init(provider: StockServiceProvider) {
        self.provider = provider
    }
    
    @MainActor
    func onInputTextChange(inputText text: String) {
        Task {
            self.pageState = .loading
            do {
                let stocks = try await stockService.fetchStock(forKey: text)
                stockList = stocks
                self.pageState = .results
            } catch _ as StockServiceError {
                self.pageState = .empty
            }
            catch let repoError as RepositoryError {
                if repoError == .taskIsCancelled {
                    print("Repository task was cancelled")
                }
            } catch {
                self.pageState = .error
            }
        }
    }
    
    @MainActor func clearSearch() {
        self.stockList = []
        self.inputText = ""
        self.pageState = .initial
    }
    
    @Published var inputText: String = ""
    
    @Published var stockList: [Stock] = []
}
