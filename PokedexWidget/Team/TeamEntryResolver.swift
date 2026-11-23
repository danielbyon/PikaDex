import Foundation
import PokedexCore

/// Builds immutable widget entries from saved teams and the persisted game.
///
/// A valid configured team is selected first. Otherwise, each operation uses
/// the first saved team for one current-game snapshot.
struct TeamEntryResolver: Sendable {

    private let storage: any TeamStorage
    private let loadCurrentGame: @Sendable () -> Game

    init(storage: any TeamStorage, loadCurrentGame: @escaping @Sendable () -> Game) {
        self.storage = storage
        self.loadCurrentGame = loadCurrentGame
    }

    func placeholderEntry(date: Date? = nil) -> TeamEntry {
        let currentGame = loadCurrentGame()
        let firstTeam = storage.loadTeams(forGame: currentGame)?.first
        return TeamEntry(date: date ?? Date(), team: firstTeam, game: nil)
    }

    func configuredEntry(
        gameRawValue: String?,
        teamIdentifier: String?,
        date: Date? = nil
    ) -> TeamEntry {
        let currentGame = loadCurrentGame()

        if let gameRawValue,
           let configuredGame = Game(rawValue: gameRawValue),
           let teamIdentifier,
           let teams = storage.loadTeams(forGame: configuredGame),
           let team = teams.first(where: { $0.internalID.uuidString == teamIdentifier }) {
            return TeamEntry(date: date ?? Date(), team: team, game: gameRawValue)
        }

        let firstTeam = storage.loadTeams(forGame: currentGame)?.first
        return TeamEntry(date: date ?? Date(), team: firstTeam, game: nil)
    }

    /// Decodes the saved game value, using Sword when it is missing or invalid.
    static func decodePersistedGame(from data: Data?) -> Game {
        guard let data,
              let game = try? JSONDecoder().decode(Game.self, from: data) else {
            return .sword
        }
        return game
    }

}
