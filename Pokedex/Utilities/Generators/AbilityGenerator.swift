//
//  AbilityGenerator.swift
//  Pokedex
//
//  Created by Daniel Byon on 1/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import CoreData

extension Ability {

    static func generateBlaze() -> Ability {
        generate(withName: "Blaze")
    }

    static func generate(withName name: String) -> Ability {
        let moc = Dependencies.container.viewContext
        let fetchRequest = Ability.fetchRequest(forName: name)
        let ability = try! moc.fetch(fetchRequest).first!
        return ability
    }

}
