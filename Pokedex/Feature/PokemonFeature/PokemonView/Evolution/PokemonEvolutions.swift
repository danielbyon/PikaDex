//
//  PokemonEvolutions.swift
//  
//
//  Created by Daniel Byon on 10/14/22.
//

import PokedexUI
import SwiftUI

struct PokemonEvolutions: View {

    let evolutions: [Evolution]

    var body: some View {
        ForEach(evolutions) { evolution in
            NavigationLink(value: Route.content(.evolutionPokemonForm(evolution.from, pokedex: .national))) {
                PokemonEvolutionFrom(evolution: evolution)
            }
            PokemonEvolution(evolution: evolution)
            NavigationLink(value: Route.content(.evolutionPokemonForm(evolution.to, pokedex: .national))) {
                PokemonEvolutionTo(evolution: evolution)
            }
            PokemonEvolutionConditions(
                conditionInfo: evolution.conditionInfo,
                conditionInfo2: evolution.conditionInfo2
            )
        }
        .listRowSeparator(.hidden)
    }

}

//struct PokemonEvolutions_Previews: PreviewProvider {
//    static var previews: some View {
//        PokemonEvolutions()
//    }
//}

private struct PokemonEvolutionFrom: View {

    let evolution: Evolution

    var body: some View {
        HStack {
            Group {
                if evolution.from.formName == evolution.from.name {
                    Text(evolution.from.name)
                } else {
                    VStack(alignment: .leading) {
                        Text(evolution.from.name)
                        Text(evolution.from.formName)
                            .monospacedCaption()
                    }
                }
            }
            .monospacedBody()
            .multilineTextAlignment(.leading)
            Spacer()
        }
    }

}

private struct PokemonEvolutionTo: View {

    let evolution: Evolution

    var body: some View {
        HStack {
            Spacer()
            Group {
                if evolution.to.formName == evolution.to.name {
                    Text(evolution.to.name)
                } else {
                    VStack(alignment: .trailing) {
                        Text(evolution.to.name)
                        Text(evolution.to.formName)
                            .monospacedCaption()
                    }
                }
            }
            .monospacedBody()
            .multilineTextAlignment(.trailing)
        }
    }

}

private struct PokemonEvolutionConditions: View {

    let conditionInfo: String?
    let conditionInfo2: String?

    var body: some View {
        if conditionInfo != nil || conditionInfo2 != nil {
            VStack {
                Divider()
                if let conditionInfo {
                    Text(conditionInfo)
                }
                if let conditionInfo2 {
                    Text(conditionInfo2)
                }
            }
            .monospacedCaption()
            .multilineTextAlignment(.leading)
        }
    }

}

private struct PokemonEvolution: View {

    let evolution: Evolution

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Spacer()
                EvolutionSprite(
                    spriteName: evolution.from.spriteName,
                    borderColor: Color(evolution.from.color.uiColor)
                )
                Spacer()
            }
            Spacer(minLength: 8.0)
            VStack {
                if let sprite = evolution.sprite {
                    sprite
                        .scaledToFit()
                        .frame(width: 24.0, height: 24.0)
                }
                Text(evolution.methodInfo)
                    .monospacedCaption()
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Image(systemName: "arrow.right")
                    .scaledToFit()
                    .frame(width: 20.0, height: 20.0)
            }
            Spacer(minLength: 8.0)
            VStack(spacing: 0) {
                Spacer()
                EvolutionSprite(
                    spriteName: evolution.to.spriteName,
                    borderColor: Color(evolution.to.color.uiColor)
                )
                Spacer()
            }
        }
    }

}

private struct EvolutionSprite: View {

    let spriteName: String
    let borderColor: Color

    var body: some View {
        Sprite(spriteName)
            .background(
                RoundedRectangle(cornerRadius: 4.0)
                    .stroke()
                    .foregroundColor(borderColor))
    }

}

private extension Evolution {

    var conditionInfo: String? {
        guard let condition = condition else { return nil }
        return makeConditionInfoString(for: condition)
    }

    var conditionInfo2: String? {
        guard let condition = condition2 else { return nil }
        return makeConditionInfoString(for: condition)
    }

    private func makeConditionInfoString(for condition: Evolution.Condition) -> String {
        switch condition {
        case .deviceHeldUpsideDown:
            return "Device held upside down"
        case .gender(let gender):
            return gender.rawValue.capitalized
        case .haveAbility(let ability):
            return "Have ability \(ability)"
        case .other(let string):
            return string
        case .partyMemberType(let type):
            return "Have a \(type)-type Pokémon in your party"
        case .region(let region):
            return "\(region.name) region"
        case .timeOfDay(let timeOfDay):
            return timeOfDay.rawValue
        case .weather(let weather):
            return weather.rawValue.capitalized
        }
    }

    var methodInfo: String {
        switch method {
        case .completeBattlePerformingAction(let action):
            return "Finish battle with \(action)"
        case .friendship:
            return "High Friendship"
        case .levelUp(let level):
            return "Level \(level)"
        case .levelUpHoldingItem(let item, _):
            return "Level up holding \(item)"
        case .levelUpInArea(let area):
            return "Level up (\(area))"
        case .levelUpKnowingMove(let move):
            return "Level up knowing \(move)"
        case .levelUpWithPartyMember(let pokemon):
            return "Level up with \(pokemon) in party"
        case .levelUpWithStats(let stats):
            return "Level up (\(stats))"
        case .other(let string):
            return string
        case .trade:
            return "Trade"
        case .tradeForPokemon(let pokemon):
            return "Trade for \(pokemon)"
        case .tradeHoldingItem(let item, _):
            return "Trade holding \(item)"
        case .trainerAction(let action):
            return action
        case .useItem(let item, _):
            return "Use \(item)"
        }
    }

    var sprite: Image? {
        switch method {
        case .completeBattlePerformingAction,
                .other:
            return nil
        case .friendship:
            return Image("friend-ball")
        case .levelUp,
                .levelUpInArea,
                .levelUpWithStats,
                .levelUpKnowingMove,
                .levelUpWithPartyMember:
            return Image("rare-candy")
        case .levelUpHoldingItem(_, let spriteName),
                .tradeHoldingItem(_, let spriteName),
                .useItem(_, let spriteName):
            return Image(spriteName)
        case .trade,
                .tradeForPokemon:
            return Image(systemName: "arrow.right.arrow.left.circle")
        case .trainerAction:
            return nil
        }
    }

}




private extension StoredEvolution {

    var borderColor: Color {
        Color(from.color.uiColor)
    }

//    var sprite: Image? {
//        switch method {
//        case .completeBattlePerformingAction,
//                .other:
//            return nil
//        case .friendship:
//            return Image("friend-ball")
//        case .levelUp,
//                .levelUpInArea,
//                .levelUpWithStats,
//                .levelUpKnowingMove,
//                .levelUpWithPartyMember:
//            return Image("rare-candy")
//        case .levelUpHoldingItem(let item),
//                .tradeHoldingItem(let item),
//                .useItem(let item):
//            return Image(item.spriteName)
//        case .trade,
//                .tradeForPokemon:
//            return Image(systemName: "arrow.right.arrow.left.circle")
//        case .trainerAction:
//            return nil
//        }
//    }

    var spriteName: String {
        return "rare-candy"
    }

    var methodInfo: String {
        switch method {
        case .completeBattlePerformingAction(let action):
            return "Finish battle with \(action)"
        case .friendship:
            return "High Friendship"
        case .levelUp(let level):
            return "Level \(level)"
        case .levelUpHoldingItem(let item):
            return "Level up holding \(item.name)"
        case .levelUpInArea(let area):
            return "Level up (\(area))"
        case .levelUpKnowingMove(let move):
            return "Level up knowing \(move.name)"
        case .levelUpWithPartyMember(let pokemon):
            return "Level up with \(pokemon.name) in party"
        case .levelUpWithStats(let stats):
            return "Level up (\(stats))"
        case .other(let string):
            return string
        case .trade:
            return "Trade"
        case .tradeForPokemon(let pokemon):
            return "Trade for \(pokemon.name)"
        case .tradeHoldingItem(let item):
            return "Trade holding \(item.name)"
        case .trainerAction(let action):
            return action
        case .useItem(let item):
            return "Use \(item.name)"
        }
    }

    var conditionInfo: String? {
        guard let condition = condition else { return nil }
        switch condition {
        case .deviceHeldUpsideDown:
            return "Device held upside down"
        case .gender(let gender):
            return gender.rawValue.capitalized
        case .haveAbility(let ability):
            return "Have ability \(ability.name)"
        case .other(let string):
            return string
        case .partyMemberType(let type):
            return "Have a \(type)-type Pokémon in your party"
        case .region(let region):
            return "\(region.name) region"
        case .timeOfDay(let timeOfDay):
            return timeOfDay.rawValue
        case .weather(let weather):
            return weather.rawValue.capitalized
        }
    }

}
