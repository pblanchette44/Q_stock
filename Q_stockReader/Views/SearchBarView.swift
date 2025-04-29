//
//  SearchBarView.swift
//  Q_stockReader
//
//  Created by Philippe Blanchette on 2025-04-29.
//

import SwiftUI

protocol SearchBarManager: ObservableObject {
    @MainActor func onInputTextChange(inputText text: String)
    @MainActor func clearSearch()
    var inputText: String { get set }
}

struct SearchBarView<VM>: View where VM: SearchBarManager {
    
    @ObservedObject var viewModel: VM
    @FocusState private var focus: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .padding(.leading, 12)
                
                TextField(
                    text: $viewModel.inputText,
                    prompt: Text("Search for ticker or company name"),
                    label: {
                        Text("Search")
                    }
                )
                .focused($focus)
                .onChange(of: viewModel.inputText, perform: { newValue in
                    if focus && !newValue.isEmpty {
                        viewModel.onInputTextChange(inputText: newValue)
                    }
                })
                .padding(.vertical, 12)
                
                if !viewModel.inputText.isEmpty {
                    Image(systemName: "xmark.circle")
                        .padding(.trailing, 12)
                        .onTapGesture {
                            self.viewModel.clearSearch()
                        }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }

    }
}
