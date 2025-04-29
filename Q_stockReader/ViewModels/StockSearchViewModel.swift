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
    
    // TODO: This has been put lazy If we ever want to put some logic to return some different services based off some runtime conditions like network state
    private lazy var stockService: any StockFetchingService = {
        provider.resolve()
    }()
    
    private let provider: any Provider
    
    @Published var pageState: PageState = .initial
    
    init(provider: any Provider) {
        self.provider = provider
    }
    
    /*
        The main way to fetch content, this is triggered on editing the search bar
     */
    @MainActor
    func onInputTextChange(inputText text: String) {
        Task {
            self.pageState = .loading
            do {
                // golden path, where we fetch the stock list and update the published set of value
                let stocks = try await stockService.fetchStock(forKey: text)
                stockList = stocks
                self.pageState = .results
                
            } catch _ as StockServiceError {
                // we treat the empty state as an error for convenience
                self.pageState = .empty
            }
            catch let repoError as RepositoryError {
                // we log if we are cancelling the task because the user is typing too fast
                if repoError == .taskIsCancelled {
                    print("debug::Repository task was cancelled")
                }
            } catch {
                // a generic error handler to display the user,we display all error case as one case to the view.
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
