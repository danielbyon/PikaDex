//
//  DataStore.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/19/21.
//  Copyright © 2021 Daniel Byon. All rights reserved.
//

import Dependencies
import Foundation
import CoreData
import SwiftUI

public final class DataStore: NSObject, ObservableObject {

    public static var pokedex = DataStore(container: .pokedexContainer)
    public static var userData = DataStore(container: .userDataContainer)

    public var viewContext: NSManagedObjectContext { container.viewContext }

    private let container: NSPersistentContainer

    public init(container: NSPersistentContainer) {
        self.container = container
    }

    public func fetch<T: Queryable>(_: T.Type, filter: T.Filter) throws -> [T] {
        let request = filter.makeFetchRequest(self)
        return try viewContext.fetch(request).map(T.init)
    }

    public func save<T: Persistable>(_ object: T) throws {
        let _ = object.makeModelObject(context: viewContext)
        try viewContext.save()
    }

    public func remove<T: Queryable>(_: T.Type, filter: T.Filter) throws {
        let request = filter.makeFetchRequest(self)
        let objects = try viewContext.fetch(request)
        objects.forEach {
            viewContext.delete($0)
        }
        try viewContext.save()
    }

}

private enum PokedexDataStoreKey: DependencyKey {
    static var liveValue: DataStore = .init(container: .pokedexContainer)
}

private enum UserDataDataStoreKey: DependencyKey {
    static var liveValue: DataStore = .init(container: .userDataContainer)
}

public extension DependencyValues {

    var pokedexDataStore: DataStore {
        get { self[PokedexDataStoreKey.self] }
        set { self[PokedexDataStoreKey.self] = newValue }
    }

    var userDataDataStore: DataStore {
        get { self[UserDataDataStoreKey.self] }
        set { self[UserDataDataStoreKey.self] = newValue }
    }

}
