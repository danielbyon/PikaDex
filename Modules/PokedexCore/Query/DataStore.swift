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

    /// Compatibility access to the cached production catalog.
    ///
    /// New composition code should use the ready values returned by
    /// `PersistenceBootstrap.production()`. This accessor resolves the cached
    /// bootstrap once and never performs bootstrap work during fetches.
    public static let pokedex: DataStore = {
        do {
            return try PersistenceBootstrap.production().pokedex
        } catch {
            return DataStore(error: error)
        }
    }()

    /// Compatibility access to the cached production user-data store.
    public static let userData: DataStore = {
        do {
            return try PersistenceBootstrap.production().userData
        } catch {
            return DataStore(error: error)
        }
    }()

    internal let contextResult: Result<NSManagedObjectContext, Error>

    /// Creates a data store from a container whose persistent stores have
    /// already loaded successfully.
    public init(container: NSPersistentContainer) {
        self.contextResult = .success(container.viewContext)
    }

    internal init(error: Error) {
        self.contextResult = .failure(error)
    }

    public func fetch<T: Queryable>(_: T.Type, filter: T.Filter) throws -> [T] {
        let viewContext = try contextResult.get()
        let request = filter.makeFetchRequest(self)
        return try viewContext.fetch(request).map(T.init)
    }

    public func save<T: Persistable>(_ object: T) throws {
        let viewContext = try contextResult.get()
        let _ = object.makeModelObject(context: viewContext)
        try viewContext.save()
    }

    public func remove<T: Queryable>(_: T.Type, filter: T.Filter) throws {
        let viewContext = try contextResult.get()
        let request = filter.makeFetchRequest(self)
        let objects = try viewContext.fetch(request)
        objects.forEach {
            viewContext.delete($0)
        }
        try viewContext.save()
    }

}

private enum PreviewPersistenceStores {
    static let result: Result<PersistenceStores, Error> = Result {
        try PersistenceBootstrap.preview()
    }

    static func dataStore(_ keyPath: KeyPath<PersistenceStores, DataStore>) -> DataStore {
        do {
            return try result.get()[keyPath: keyPath]
        } catch {
            return DataStore(error: error)
        }
    }
}

private extension DataStore {
    static func unconfiguredTestStore(named name: String) -> DataStore {
        DataStore(error: PersistenceBootstrapError(
            stage: .testConfiguration,
            modelName: name,
            recoveryContext: .injectTestStore
        ))
    }
}

private enum PokedexDataStoreKey: DependencyKey {
    static let liveValue: DataStore = .pokedex
    static let previewValue = PreviewPersistenceStores.dataStore(\.pokedex)
    static let testValue = DataStore.unconfiguredTestStore(named: "Pokedex")
}

private enum UserDataDataStoreKey: DependencyKey {
    static let liveValue: DataStore = .userData
    static let previewValue = PreviewPersistenceStores.dataStore(\.userData)
    static let testValue = DataStore.unconfiguredTestStore(named: "UserData")
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
