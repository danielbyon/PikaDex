//
//  Team+PokePasteConvertible.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/7/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension Team: PokePasteConvertible {

    var pokePaste: String {

        func renderNameLine(_ member: TeamMember) -> String {
            var components: [String] = []

            // Name, form name & nickname
            var name = member.pokemon
            if member.formName != member.pokemon {
                var formName = member.formName
                formName = formName
                    .replacingOccurrences(of: member.pokemon, with: "")
                    .trimmingCharacters(in: .whitespaces)
                    .replacingOccurrences(of: "  ", with: " ") // Remove double spaces
                    .replacingOccurrences(of: " ", with: "-") // Convert spaces to hyphens
                name += "-\(formName)"
            }

            if !member.nickname.isEmpty {
                name = "\(member.nickname) (\(name))"
            }
            components.append(name)

            // Gender
            switch member.gender {
            case .male:
                components.append("(M)")
            case .female:
                components.append("(F)")
            case .unspecified:
                break
            }

            // Item
            if let item = member.heldItem {
                components.append("@ \(item)")
            }

            return components.joined(separator: " ")
        }

        func renderEVs(_ member: TeamMember) -> String {
            "EVs: \(member.hp.ev) HP / \(member.attack.ev) Atk / \(member.defense.ev) Def / \(member.specialAttack.ev) SpA / \(member.specialDefense.ev) SpD / \(member.speed.ev) Spe"
        }

        func renderIVs(_ member: TeamMember) -> String {
            "IVs: \(member.hp.iv) HP / \(member.attack.iv) Atk / \(member.defense.iv) Def / \(member.specialAttack.iv) SpA / \(member.specialDefense.iv) SpD / \(member.speed.iv) Spe"
        }

        func renderAbility(_ member: TeamMember) -> String? {
            guard let ability = member.ability else { return nil }
            return "Ability: \(ability)"
        }

        func renderShiny(_ member: TeamMember) -> String? {
            guard member.isShiny else { return nil }
            return "Shiny: Yes"
        }

        func renderLevel(_ member: TeamMember) -> String {
            "Level: \(member.level)"
        }

        func renderHappiness(_ member: TeamMember) -> String? {
            guard member.happiness < 255 else { return nil }
            return "Happiness: \(member.happiness)"
        }

        func renderNature(_ member: TeamMember) -> String? {
            guard let nature = member.nature else { return nil }
            return "\(nature) Nature"
        }

        func renderMoves(_ member: TeamMember) -> String {
            [
                member.move1,
                member.move2,
                member.move3,
                member.move4
            ]
            .compactMap { $0 }
            .map { "- \($0)" }
            .joined(separator: "\n")
        }

        var exportedMembers: [String] = []
        for member in members {
            var memberComponents: [String?] = []
            memberComponents.append(renderNameLine(member))
            memberComponents.append(renderEVs(member))
            memberComponents.append(renderIVs(member))
            memberComponents.append(renderAbility(member))
            memberComponents.append(renderShiny(member))
            memberComponents.append(renderLevel(member))
            memberComponents.append(renderHappiness(member))
            memberComponents.append(renderNature(member))
            memberComponents.append(renderMoves(member))

            let exportedMember = memberComponents
                .compactMap { $0 }
                .joined(separator: "\n")
            exportedMembers.append(exportedMember)
        }
        return exportedMembers
            .joined(separator: "\n\n")
    }

}
