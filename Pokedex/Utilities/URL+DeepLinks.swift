//
//  URL+DeepLinks.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/15/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import PokedexCore

extension URL {

    // MARK: General

    var isDeepLink: Bool {
        scheme == "pikadex"
    }

    var game: Game? {
        let components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        guard let rawValue = components?.queryItems?.first(where: { $0.name == "game" })?.value,
           let game = Game(rawValue: rawValue) else {
            return nil
        }
        return game
    }

    // MARK: App Sections

    var supportedHost: SupportedHost? {
        switch host {
        case "pokemon":
            return .pokemon
        case "teams":
            return .teams
        default:
            return nil
        }
    }

    enum SupportedHost: String {
        case pokemon
        case teams
    }

    // MARK: Pokemon

    init?(pokemon: String) {
        self.init(string: "pikadex://pokemon/\(pokemon)")
    }

    var pokemon: String? {
        guard case .pokemon = supportedHost else { return nil }
        return lastPathComponent
    }

    // MARK: Teams

    init?(teamID: String, game: String?) {
        self.init(string: "pikadex://teams/\(teamID)?game=\(game ?? "")")
    }

    var teamID: String? {
        guard case .teams = supportedHost else { return nil }
        return lastPathComponent
    }

}
