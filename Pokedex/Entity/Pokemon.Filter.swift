//
//  Pokemon.Filter.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/19/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import AppSupport

extension Pokemon {

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
            let title: String
            let keyPath: String
        }

        public enum SortBy: String, CaseIterable, Codable {
            case number
            case name
        }

        public enum SortOrder: Int, CaseIterable, Codable {

            case ascending
            case descending

            var title: String {
                switch self {
                case .ascending: return "Ascending"
                case .descending: return "Descending"
                }
            }

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

extension Pokemon.Filter: Equatable {

    public static func == (lhs: Pokemon.Filter, rhs: Pokemon.Filter) -> Bool {
        lhs.filterBy == rhs.filterBy && lhs.sortBy == rhs.sortBy && lhs.sortOrder == rhs.sortOrder
    }

}

extension Pokemon.Filter: UserDefaultPersistable { }

extension Pokemon.Filter.FilterBy: Equatable { }

extension Pokemon.Filter.FilterBy: Identifiable {

    public var id: String { title }

}

extension Pokemon.Filter.SortBy: Equatable { }

extension Pokemon.Filter.SortBy: Identifiable {

    public var id: String { rawValue }

}

extension Pokemon.Filter.SortOrder: Equatable { }

extension Pokemon.Filter.SortOrder: Identifiable {

    public var id: Int { rawValue }

}
