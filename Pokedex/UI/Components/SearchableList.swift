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

struct SearchableList2<Element, Content>: View where Element: Hashable & Identifiable & CanonicallyNamed, Content: View {

    @StateObject private var viewModel: SearchableListViewModel2<Element>
    private let searchPlaceholder: String
    @ViewBuilder private let content: (Element) -> Content

    var body: some View {
        List {
            AlternatingBackgroundForEach(viewModel.filteredObjects) { object in
                self.content(object)
            }
        }
        .listStyle(PlainListStyle())
        .searchable(text: $viewModel.searchText, prompt: searchPlaceholder)
    }

    init(objects: [Element], searchPlaceholder: String = "Search", @ViewBuilder content: @escaping (Element) -> Content) {
        self._viewModel = .init(wrappedValue: SearchableListViewModel2(objects: objects))
        self.searchPlaceholder = searchPlaceholder
        self.content = content
    }

}

final class SearchableListViewModel2<Element>: ObservableObject where Element: Identifiable & CanonicallyNamed {

    @Published var searchText = ""
    @Published private(set) var filteredObjects: [Element] = []
    private(set) var objects: [Element]

    private var cancellable: AnyCancellable?

    init(objects: [Element]) {
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




struct SearchableList<Element, Content>: View where Element: NSFetchRequestResult & Hashable & Identifiable & CanonicallyNamed, Content: View {

    @StateObject private var viewModel: SearchableListViewModel<Element>
    private let searchPlaceholder: String
    @ViewBuilder private let content: (Element) -> Content

    var body: some View {
        List {
            AlternatingBackgroundForEach(viewModel.filteredObjects) { object in
                self.content(object)
            }
        }
        .listStyle(PlainListStyle())
        .searchable(text: $viewModel.searchText, prompt: searchPlaceholder)
    }

    init(objects: FetchedResults<Element>, searchPlaceholder: String = "Search", @ViewBuilder content: @escaping (Element) -> Content) {
        self._viewModel = .init(wrappedValue: SearchableListViewModel(objects: objects))
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
