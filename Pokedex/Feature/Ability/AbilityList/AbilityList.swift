//
//  AbilityList.swift
//  
//
//  Created by Daniel Byon on 10/21/22.
//

import PokedexUI
import SwiftUI

public struct AbilityList: View {

    @Query private var abilities: QueryResults<Ability>

    private let game: Game

    public var body: some View {
        SearchableList(
            items: abilities,
            query: $abilities.query.toString(),
            searchPrompt: "Search for an ability",
            id: \.name
        ) { ability in
            NavigationLink(value: Route.content(.ability(ability, game: game, pokedex: .national))) {
                AbilityCell(ability: ability)
            }
        }
        .navigationTitle("Abilities")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                HomeButton()
            }
        }
        .onAppear {
            $abilities.wrappedValue = .init(game: game)
        }
    }

    public init(game: Game) {
        self.game = game
    }

}

struct AbilityList_Previews: PreviewProvider {
    static var previews: some View {
        AbilityList(game: .sword)
    }
}
