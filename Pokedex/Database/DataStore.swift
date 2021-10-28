//
//  DataStore.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/19/21.
//  Copyright © 2021 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI

public final class DataStore: NSObject, ObservableObject {

    public var viewContext: NSManagedObjectContext { container.viewContext }

    private let container: NSPersistentContainer

    public init(container: NSPersistentContainer) {
        self.container = container
    }

}

public struct DataStoreEnvironmentKey: EnvironmentKey {

    public static var defaultValue = DataStore(container: Dependencies.container)

}

public extension EnvironmentValues {

    var dataStore: DataStore {
        get { self[DataStoreEnvironmentKey.self] }
        set { self[DataStoreEnvironmentKey.self] = newValue }
    }

}

public extension View {

    func dataStore(_ dataStore: DataStore) -> some View {
        environment(\.dataStore, dataStore)
    }

}
