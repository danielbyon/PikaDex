//
//  TeamCell.swift
//  
//
//  Created by Daniel Byon on 10/28/22.
//

import PokedexUI
import SwiftUI

struct TeamCell: View {

    let team: Team
    let game: Game

    @Query private var member1Query: QueryResults<PokemonDetailForm>
    @Query private var member2Query: QueryResults<PokemonDetailForm>
    @Query private var member3Query: QueryResults<PokemonDetailForm>
    @Query private var member4Query: QueryResults<PokemonDetailForm>
    @Query private var member5Query: QueryResults<PokemonDetailForm>
    @Query private var member6Query: QueryResults<PokemonDetailForm>

    var member1SpriteName: String? { member1Query.first?.spriteName }
    var member2SpriteName: String? { member2Query.first?.spriteName }
    var member3SpriteName: String? { member3Query.first?.spriteName }
    var member4SpriteName: String? { member4Query.first?.spriteName }
    var member5SpriteName: String? { member5Query.first?.spriteName }
    var member6SpriteName: String? { member6Query.first?.spriteName }

    var body: some View {
        Card {
            VStack(alignment: .leading) {
                HStack {
                    Text(team.name)
                        .monospacedTitle()
                        .bold()
                    Spacer()
                }

                Card {
                    HStack(spacing: 0) {
                        Group {
                            sprite(spriteName: member1SpriteName)
                            Spacer(minLength: 0)
                            sprite(spriteName: member2SpriteName)
                            Spacer(minLength: 0)
                            sprite(spriteName: member3SpriteName)
                            Spacer(minLength: 0)
                            sprite(spriteName: member4SpriteName)
                            Spacer(minLength: 0)
                            sprite(spriteName: member5SpriteName)
                            Spacer(minLength: 0)
                        }
                        sprite(spriteName: member6SpriteName)
                    }
                }
            }
        }
        .onAppear {
            updateQueries()
        }
    }

    @ViewBuilder
    private func sprite(spriteName: String?) -> some View {
        if let spriteName {
            Sprite(spriteName)
        } else {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 40, height: 40)
        }
    }

    func updateQueries() {
        if let member1 = team.members[safe: 0] {
            $member1Query.wrappedValue = .init(pokemonName: member1.pokemon, formName: member1.formName, game: game)
        }
        if let member2 = team.members[safe: 1] {
            $member2Query.wrappedValue = .init(pokemonName: member2.pokemon, formName: member2.formName, game: game)
        }
        if let member3 = team.members[safe: 2] {
            $member3Query.wrappedValue = .init(pokemonName: member3.pokemon, formName: member3.formName, game: game)
        }
        if let member4 = team.members[safe: 3] {
            $member4Query.wrappedValue = .init(pokemonName: member4.pokemon, formName: member4.formName, game: game)
        }
        if let member5 = team.members[safe: 4] {
            $member5Query.wrappedValue = .init(pokemonName: member5.pokemon, formName: member5.formName, game: game)
        }
        if let member6 = team.members[safe: 5] {
            $member6Query.wrappedValue = .init(pokemonName: member6.pokemon, formName: member6.formName, game: game)
        }
    }

}

struct TeamCell_Previews: PreviewProvider {
    static var previews: some View {
        TeamCell(team: .stub1, game: .sword)
    }
}
