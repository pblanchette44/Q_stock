//
//  StockSearchView.swift
//  Q_stockReader
//
//  Created by Philippe Blanchette on 2025-04-29.
//

import SwiftUI

struct StockView<T>: View where T: Provider, T:ObservableObject {
    @EnvironmentObject private var t: T
    
    var body: some View {
        StockSearchView(provider: t)
        .padding()
    }
}

struct StockSearchView: View {
    @StateObject var viewModel: StockViewModel
    
    init(provider: any Provider) {
        self._viewModel = StateObject(wrappedValue: .init(provider: provider))
    }
    
    var body: some View {
            VStack {
                // this can lead to prop drilling so we should watchout for a better way to pass the viewModel in any future updates
                SearchBarView(viewModel: viewModel)
                
                // we parse the viewModel page state to display a relevant contentView
                switch viewModel.pageState {
                case .initial:
                    // The base View when the user arrives in the app
                    initialView
                case .empty:
                    // a warning message when the results are empty
                    emptyView
                case .error:
                    // an error message in cases network or data parsing fails
                    errorView
                case .results:
                    // the listView containing all the fetched data
                    resultView
                case .loading:
                    // a skeleton loader view which serves as an activity indicator
                    loadingView()
                }
            }
    }
    
    struct StockRow: View {
        
        var stock: Stock
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(stock.ticker)
                    .font(.title2)
                    .bold()
                Text(stock.name)
                    .font(.subheadline)
                    .padding(.bottom, 6)
                
                HStack {
                    Group {
                        Text("Avg.price")
                            .bold()
                        Spacer()
                        Text(String(format: "%.2f", stock.averagePrice))
                    }
                    .font(.body)
                }
                
                HStack {
                    Group {
                        Text("Current price")
                            .bold()
                        Spacer()
                        Text(String(format: "%.2f", stock.currentPrice))
                    }
                    .font(.body)
                }
                
                Divider()
            }
            .frame(minHeight: 88)
        }
    }
    
    var initialView: some View {
        VStack {
            Spacer()
            Text("Discover")
                .font(.title2)
                .padding(.bottom, 12)
            Text("Search for stocks by ticket or company name and get their current and average prices")
                .multilineTextAlignment(.center)
                .font(.body)
                .padding(.horizontal, 12)
            Spacer()
        }
    }
    
    var emptyView: some View {
        VStack {
            Spacer()
            Text("No Results")
                .font(.title2)
                .padding(.bottom, 12)
            Text("Looks like there's no stock matching your search")
                .multilineTextAlignment(.center)
                .font(.body)
                .padding(.horizontal, 12)
            Spacer()
        }
    }
    
    var errorView: some View {
        VStack {
            Spacer()
            Text("An error occurred")
                .font(.title2)
                .padding(.bottom, 12)
            Text("There was an error performing your search")
                .multilineTextAlignment(.center)
                .font(.body)
            Spacer()
        }
    }
    
    var resultView: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(viewModel.stockList) { temp in
                    StockRow(stock: temp)
                }
            }
            .padding(.top, 12)
            Spacer()
        }
        .scrollIndicators(.hidden)
    }
    
    struct loadingView: View {
        
        @State private var animate: Bool = false
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(0..<10) { index in
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: .init(
                                        colors: [.gray.opacity(0.2), Color.black.opacity(0.2)]
                                    ),
                                    startPoint: animate ? .topLeading : .bottomLeading,
                                    endPoint: animate ? .bottomTrailing : .topLeading
                                )
                            )
                            .cornerRadius(6)
                            .frame(minHeight: 88)
                            .padding(.bottom, 12)
                            .animation(.linear(duration: 2).repeatForever(autoreverses: true), value: animate)
                            .onAppear {
                                animate = true
                            }
                    }
                }
                .padding(.top, 12)
                Spacer()
            }
        }
        
    }
}
