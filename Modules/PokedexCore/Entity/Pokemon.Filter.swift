//
//  StoredPokemon.Filter.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/19/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import AppSupport

extension StoredPokemon {

    public struct Filter: Codable {
//    public class Filter: ObservableObject, Codable {

//        @Published
        public var filterBy: FilterBy
//        {
//            willSet {
//                objectWillChange.send()
//            }
//        }
//        @Published
        public var sortBy: SortBy
//        {
//            willSet {
//                objectWillChange.send()
//            }
//        }
//        @Published
        public var sortOrder: SortOrder
//        {
//            willSet {
//                objectWillChange.send()
//            }
//        }

        public static func defaultFilter(forGame game: Game) -> Filter {
            Filter(filterBy: game.nationalFilterBy, sortBy: .number, sortOrder: .ascending)
        }

        public struct FilterBy: Codable {
            public let title: String
            public let keyPath: String
        }

        public enum SortBy: String, CaseIterable, Codable {
            case number
            case name
        }

        public enum SortOrder: String, CaseIterable, Codable {

            case ascending = "Ascending"
            case descending = "Descending"

        }

        private enum CodingKeys: String, CodingKey {
            case filterBy
            case sortBy
            case sortOrder
        }

        public init(filterBy: FilterBy, sortBy: SortBy, sortOrder: SortOrder) {
            self.filterBy = filterBy
            self.sortBy = sortBy
            self.sortOrder = sortOrder
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.filterBy = try container.decode(FilterBy.self, forKey: .filterBy)
            self.sortBy = try container.decode(SortBy.self, forKey: .sortBy)
            self.sortOrder = try container.decode(SortOrder.self, forKey: .sortOrder)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(filterBy, forKey: .filterBy)
            try container.encode(sortBy, forKey: .sortBy)
            try container.encode(sortOrder, forKey: .sortOrder)
        }

    }

}

extension StoredPokemon.Filter: Equatable {

    public static func == (lhs: StoredPokemon.Filter, rhs: StoredPokemon.Filter) -> Bool {
        lhs.filterBy == rhs.filterBy && lhs.sortBy == rhs.sortBy && lhs.sortOrder == rhs.sortOrder
    }

}

extension StoredPokemon.Filter: Hashable { }

extension StoredPokemon.Filter: Identifiable {

    public var id: String { filterBy.id + sortBy.id + sortOrder.id }

}

extension StoredPokemon.Filter: UserDefaultPersistable { }

extension StoredPokemon.Filter.FilterBy: Equatable { }

extension StoredPokemon.Filter.FilterBy: Hashable { }

extension StoredPokemon.Filter.FilterBy: Identifiable {

    public var id: String { title }

}

extension StoredPokemon.Filter.SortBy: Equatable { }

extension StoredPokemon.Filter.SortBy: Hashable { }

extension StoredPokemon.Filter.SortBy: Identifiable {

    public var id: String { rawValue }

}

extension StoredPokemon.Filter.SortOrder: Equatable { }

extension StoredPokemon.Filter.SortOrder: Hashable { }

extension StoredPokemon.Filter.SortOrder: Identifiable {

    public var id: String { rawValue }

}
