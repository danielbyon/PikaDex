//
//  PokemonEvolutions.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/14/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokemonEvolutions: View {

    let evolutions: [Evolution]
    let onSelect: (PokemonForm) -> Void

    var body: some View {
        AlternatingBackgroundForEach(evolutions) { evolution in
            PokemonEvolution(evolution: evolution, onSelect: onSelect)
        }
    }

    init(evolutions: [Evolution], onSelect: @escaping (PokemonForm) -> Void) {
        self.evolutions = evolutions
        self.onSelect = onSelect
    }

}

struct PokemonEvolutions_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                List {
                    PokemonEvolutions(evolutions: Pokemon.generate(withName: "Eevee", game: .sword).defaultForm.evolutions!) { _ in }
                }
                .listStyle(GroupedListStyle())
            }
            NavigationView {
                List {
                    PokemonEvolutions(evolutions: Pokemon.generate(withName: "Eevee", game: .sword).defaultForm.evolutions!) { _ in }
                }
                .listStyle(GroupedListStyle())
            }
            .colorScheme(.dark)
        }
        .injectDependencies()
    }
}

private struct PokemonEvolution: View {

    let evolution: Evolution
    let onSelect: (PokemonForm) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            HStack {
                Text(evolution.from.name)
                    .monospacedBody()
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    Spacer()
                    EvolutionSprite(form: evolution.from, borderColor: Color(evolution.from.color.uiColor)).onTapGesture {
                        onSelect(evolution.from)
                    }
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
                    EvolutionSprite(form: evolution.to, borderColor: Color(evolution.to.color.uiColor)).onTapGesture {
                        onSelect(evolution.to)
                    }
                    Spacer()
                }
            }
            HStack {
                Spacer()
                Text(evolution.to.name)
                    .monospacedBody()
                    .multilineTextAlignment(.trailing)
            }
            if let conditionInfo = evolution.conditionInfo {
                Divider()
                Text(conditionInfo)
                    .monospacedCaption()
                    .multilineTextAlignment(.leading)
            }
        }
        .contentShape(Rectangle())
    }

    init(evolution: Evolution, onSelect: @escaping (PokemonForm) -> Void) {
        self.evolution = evolution
        self.onSelect = onSelect
    }

}

private struct EvolutionSprite: View {

    let form: PokemonForm
    let borderColor: Color

    var body: some View {
        PokemonFormSprite(form: form)
            .background(
                RoundedRectangle(cornerRadius: 4.0)
                    .stroke()
                    .foregroundColor(borderColor))
    }

}

private extension Evolution {

    var borderColor: Color {
        Color(from.color.uiColor)
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
        case .levelUpHoldingItem(let item),
             .tradeHoldingItem(let item),
             .useItem(let item):
            return Image(item.spriteName)
        case .trade,
             .tradeForPokemon:
            return Image(systemName: "arrow.right.arrow.left.circle")
        case .trainerAction:
            return nil
        }
    }

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
