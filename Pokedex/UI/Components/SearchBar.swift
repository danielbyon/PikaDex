//
//  SearchBar.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/6/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    var placeholder: String

    class Coordinator: NSObject, UISearchBarDelegate {

        @Binding var text: String

        private var pendingUpdate: DispatchWorkItem?

        init(text: Binding<String>) {
            _text = text
        }

        func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
            searchBar.setShowsCancelButton(true, animated: true)
            return true
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//            text = searchText
            pendingUpdate?.cancel()
            if searchText.isEmpty {
                // Immediately update if the text is empty
                text = searchText
            } else {
                pendingUpdate = DispatchWorkItem {
                    self.text = searchText
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: pendingUpdate!)
            }
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            text = ""
            searchBar.setShowsCancelButton(false, animated: true)
            searchBar.searchTextField.resignFirstResponder()
        }

        func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
            searchBar.setShowsCancelButton(false, animated: true)
            return true
        }

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }

}
