////
////  TeamCellViewModel.swift
////  
////
////  Created by Daniel Byon on 10/28/22.
////
//
//import PokedexUI
//import SwiftUI
//
//final class TeamCellViewModel: ObservableObject {
//
//    let team: Team
//    let game: Game
//
//    init(team: Team, game: Game) {
//        self.team = team
//        self.game = game
//    }
//
//    func update() {
//        if let member1 = team.members[safe: 0] {
//            $member1Query.wrappedValue = .init(pokemonName: member1.pokemon, formName: member1.formName, game: game)
//        }
//        if let member2 = team.members[safe: 1] {
//            $member2Query.wrappedValue = .init(pokemonName: member2.pokemon, formName: member2.formName, game: game)
//        }
//        if let member3 = team.members[safe: 2] {
//            $member3Query.wrappedValue = .init(pokemonName: member3.pokemon, formName: member3.formName, game: game)
//        }
//        if let member4 = team.members[safe: 3] {
//            $member4Query.wrappedValue = .init(pokemonName: member4.pokemon, formName: member4.formName, game: game)
//        }
//        if let member5 = team.members[safe: 4] {
//            $member5Query.wrappedValue = .init(pokemonName: member5.pokemon, formName: member5.formName, game: game)
//        }
//        if let member6 = team.members[safe: 5] {
//            $member6Query.wrappedValue = .init(pokemonName: member6.pokemon, formName: member6.formName, game: game)
//        }
//    }
//
//}
