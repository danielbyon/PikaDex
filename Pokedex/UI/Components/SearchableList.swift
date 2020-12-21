//
//  SearchableList.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/7/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import CoreData
import Combine

struct SearchableList<Element, Content>: View where Element: NSFetchRequestResult & Hashable & Identifiable & CanonicallyNamed, Content: View {

    @ObservedObject private var viewModel: SearchableListViewModel<Element>
    private let searchPlaceholder: String
    private let content: (Element) -> Content

    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $viewModel.searchText, placeholder: searchPlaceholder)
            List {
                AlternatingBackgroundForEach(viewModel.filteredObjects) { object in
                    self.content(object)
                }
            }
            .listStyle(PlainListStyle())
            .avoidKeyboard()
        }
    }

    init(viewModel: SearchableListViewModel<Element>, searchPlaceholder: String = "Search", content: @escaping (Element) -> Content) {
        self.viewModel = viewModel
        self.searchPlaceholder = searchPlaceholder
        self.content = content
    }

}

final class SearchableListViewModel<Element>: ObservableObject where Element: NSFetchRequestResult & Identifiable & CanonicallyNamed {

    @Published var searchText = ""
    @Published private(set) var filteredObjects: [Element] = []
    private(set) var objects: FetchedResults<Element>

    private var cancellable: AnyCancellable?

    init(objects: FetchedResults<Element>) {
        self.objects = objects
        self.filteredObjects = Array(objects)
        cancellable = $searchText
            .throttle(for: .milliseconds(300), scheduler: DispatchQueue.appUserInitiated, latest: true)
            .removeDuplicates()
            .map { query in
                guard !query.isEmpty else { return Array(objects) }
                return objects.filter { object in object.canonicalName.contains(query.lowercased()) }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.filteredObjects = $0
            }
    }

}
