//
//  SearchableList.swift
//  
//
//  Created by Daniel Byon on 9/19/22.
//

import SwiftUI

public struct SearchableList<Data, ID, Content>: View
where Data: RandomAccessCollection,
      ID: Hashable,
      Content: View {

    let items: Data
    @Binding var query: String
    let searchPrompt: String
    let id: KeyPath<Data.Element, ID>
    @ViewBuilder private let content: (Data.Element) -> Content

    @Environment(\.colorScheme) private var colorScheme

    private var backgroundColor: Color {
        Color(self.colorScheme == .dark ? UIColor.tertiarySystemBackground : UIColor.systemGray5)
    }

    public var body: some View {
        List {
            ForEach(items, id: id) { item in
                content(item)
            }
        }
        .listStyle(.plain)
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: searchPrompt)
        .autocorrectionDisabled(true)
    }

    public init(
        items: Data,
        query: Binding<String>,
        searchPrompt: String,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.items = items
        self._query = query
        self.searchPrompt = searchPrompt
        self.id = id
        self.content = content
    }

    public init(
        items: Data,
        query: Binding<String>,
        searchPrompt: String,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) where Data.Element: Identifiable, ID == Data.Element.ID {
        self.items = items
        self._query = query
        self.searchPrompt = searchPrompt
        self.id = \.id
        self.content = content
    }

}
