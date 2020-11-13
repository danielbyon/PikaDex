//
//  AbilityList.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/29/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct AbilityList: View {

    let game: Game

    @FetchRequest var abilities: FetchedResults<Ability>

    var body: some View {
        SearchableList(viewModel: SearchableListViewModel(objects: abilities), searchPlaceholder: "Search for an ability") { ability in
            NavigationLink(destination: AbilityDetail(ability: ability, game: self.game)) {
                AbilityCell(model: AbilityViewModel(ability: ability))
            }
        }
        .navigationTitle("Abilities")
    }

    init(game: Game) {
        self.game = game
        self._abilities = FetchRequest(fetchRequest: Ability.allFetchRequest(for: game))
    }

}

struct AbilityList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
        AbilityList(game: .sword)
            .injectDependencies()
        }
    }
}
