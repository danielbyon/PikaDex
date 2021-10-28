//
//  PokemonStore.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/9/21.
//  Copyright © 2021 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI

final actor PokemonStore: ObservableObject {

    let context: NSManagedObjectContext

    private var tasks: [NSFetchRequest<StoredPokemon>: Task<[StoredPokemon], Error>] = [:]

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchPokemon(withFetchRequest fetchRequest: NSFetchRequest<StoredPokemon>) async throws -> [StoredPokemon] {
//        if let task = tasks[fetchRequest] {
//            return try await task.value
//        }

        let task: Task<[StoredPokemon], Error> = Task {
            let managedObjectIDs = try await fetchPokemonWithContinuation(fetchRequest: fetchRequest)
            let pokemon = managedObjectIDs.compactMap { context.object(with: $0) as? StoredPokemon }
            return pokemon
        }

//        tasks[fetchRequest] = task

        let pokemon = try await task.value
//        tasks[fetchRequest] = nil
        return pokemon
    }

    private func fetchPokemonWithContinuation(fetchRequest: NSFetchRequest<StoredPokemon>) async throws -> [NSManagedObjectID] {
        let context = self.context
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    let pokemon = try context.fetch(fetchRequest)
                    let managedObjectIDs = pokemon.map(\.objectID)
                    continuation.resume(returning: managedObjectIDs)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

}
