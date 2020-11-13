//
//  MoveLearnsetGroup.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/27/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import CoreData

struct MoveLearnsetGroup<T: LearnsetEntry>: View {

    let title: String
    let game: Game

    @FetchRequest private var learnset: FetchedResults<T>
    private var viewModels: [MoveLearnsetViewModel] {
        learnset.compactMap { MoveLearnsetViewModel(learnsetEntry: $0) }
    }

    var body: some View {
        Group {
            if learnset.count > 0 {
                AlternatingBackgroundForEach(viewModels) { entry in
                    NavigationLink(destination: PokemonDetail(pokemon: entry.pokemonForm.pokemon, game: self.game, formIndex: entry.pokemonForm.formIndex)) {
                        Value3Cell(
                            title: entry.text,
                            subtitle: entry.subtext,
                            detail: entry.detailText,
                            image: entry.image)
                    }
                }
            } else {
                Text("No Pokémon learns this move by \(title).")
            }
        }
    }

    init(title: String, game: Game, learnsetFetchRequest: NSFetchRequest<T>) {
        self.title = title
        self.game = game
        self._learnset = FetchRequest(fetchRequest: learnsetFetchRequest, animation: .default)
    }

}

struct MoveLearnsetGroup_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                MoveLearnsetGroup(title: "Level", game: .sword, learnsetFetchRequest: LevelLearnsetEntry.fetchRequest(for: Move.generateThunderShock(), game: .sword))
            }
        }
        .injectDependencies()
    }
}
