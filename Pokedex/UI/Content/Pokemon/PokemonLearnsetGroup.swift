//
//  PokemonLearnsetGroup.swift
//  Pokedex
//
//  Created by Daniel Byon on 1/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import CoreData

struct PokemonLearnsetGroup<T: LearnsetEntry>: View {

    let title: String
    let game: Game

    @FetchRequest private var learnset: FetchedResults<T>
    private var viewModels: [PokemonLearnsetViewModel] {
        learnset.map { PokemonLearnsetViewModel(learnsetEntry: $0) }
    }

    var body: some View {
        Group {
            if learnset.count > 0 {
                AlternatingBackgroundForEach(viewModels) { entry in
                    NavigationLink(destination: MoveDetail(move: entry.move, game: self.game)) {
                        PokemonLearnsetGroupCell(move: entry.move, detailText: entry.detailText, game: self.game)
                    }
                }
            } else {
                Text("This Pokémon learns no moves by \(title).")
                    .monospacedBody()
            }
        }
    }

    init(title: String, game: Game, learnsetFetchRequest: NSFetchRequest<T>) {
        self.title = title
        self.game = game
        self._learnset = FetchRequest(fetchRequest: learnsetFetchRequest, animation: .default)
    }

}

struct PokemonLearnsetGroup_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                PokemonLearnsetGroup(title: "Level", game: .sword, learnsetFetchRequest: LevelLearnsetEntry.fetchRequest(forPokemonForm: Pokemon.generateCharizard().defaultForm))
            }
        }
        .modifier(Dependencies())
    }
}
