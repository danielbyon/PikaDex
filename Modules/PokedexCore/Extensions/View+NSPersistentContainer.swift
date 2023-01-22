//
//  View+NSPersistentContainer.swift
//  
//
//  Created by Daniel Byon on 9/20/22.
//

import CoreData
import SwiftUI

extension View {

    public func injectPersistentContainer() -> some View {
        self
            .pokedexDataStore(.pokedex)
            .userDataDataStore(.userData)
            .environment(\.managedObjectContext, NSPersistentContainer.pokedexContainer.viewContext)
    }

}
