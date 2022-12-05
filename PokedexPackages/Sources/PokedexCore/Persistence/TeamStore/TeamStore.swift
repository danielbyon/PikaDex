//
//  TeamStore.swift
//  
//
//  Created by Daniel Byon on 10/27/22.
//

import Combine
import CombineSchedulers
import Foundation

public protocol TeamStore {

    typealias Teams = [Game: [Team]]

    var teams: AnyPublisher<Teams, Never> { get }

    subscript(game: Game) -> [Team] { get set }

    func getTeams(forGame game: Game) -> [Team]
    func setTeams(_ teams: [Team], forGame game: Game)
    func saveTeam(_ team: Team, forGame game: Game)
    func removeTeam(_ team: Team, forGame game: Game)

}

public final class DefaultTeamStore: TeamStore {

    public static var shared = DefaultTeamStore()

    public var teams: AnyPublisher<Teams, Never> { cacheSubject.eraseToAnyPublisher() }

    private let storage: TeamStorage
    private let cacheScheduler: AnySchedulerOf<DispatchQueue>
    private let notificationCenter: NotificationCenter
    private let cacheSubject: CurrentValueSubject<Teams, Never>
    private var cache: Teams { cacheSubject.value }
    private var cancellables: Set<AnyCancellable> = []

    public init(
        storage: TeamStorage = UserDefaults.appGroup,
        cacheScheduler: AnySchedulerOf<DispatchQueue> = .appProcessing,
        notificationCenter: NotificationCenter = .default
    ) {
        self.storage = storage
        self.cacheScheduler = cacheScheduler
        self.notificationCenter = notificationCenter
        cacheSubject = .init(Self.loadCache(from: storage))

        cacheSubject
            .dropFirst()
            .debounce(for: 0.2, scheduler: cacheScheduler)
            .sink { updatedCache in
                debugPrint("Flushing team cache")
                Self.flushCache(updatedCache, to: storage)
                notificationCenter.post(name: .teamsUpdated, object: nil)
            }
            .store(in: &cancellables)
    }

    public subscript(game: Game) -> [Team] {
        get { getTeams(forGame: game) }
        set { setTeams(newValue, forGame: game) }
    }

    public func getTeams(forGame game: Game) -> [Team] {
        cache[game] ?? []
    }

    public func setTeams(_ teams: [Team], forGame game: Game) {
        var cache = self.cache
        cache[game] = teams
        cacheSubject.value = cache
    }

    public func saveTeam(_ team: Team, forGame game: Game) {
        var cache = self.cache
        var teams = cache[game] ?? []
        if let index = teams.firstIndex(where: { $0.internalID == team.internalID }) {
            teams[index] = team
        } else {
            teams.append(team)
        }
        cache[game] = teams
        cacheSubject.value = cache
    }

    public func removeTeam(_ team: Team, forGame game: Game) {
        var cache = self.cache
        guard var teams = cache[game],
              let index = teams.firstIndex(where: { $0.internalID == team.internalID }) else {
            return
        }
        teams.remove(at: index)
        cache[game] = teams
        cacheSubject.value = cache
    }

    static func loadCache(from storage: TeamStorage) -> Teams {
        return Game.allCases.reduce(into: [:]) { teamMap, game in
            guard let teams = storage.loadTeams(forGame: game) else {
                return
            }
            teamMap[game] = teams
        }
    }

    static func flushCache(_ cache: Teams, to storage: TeamStorage) {
        for (game, teams) in cache {
            storage.saveTeams(teams, forGame: game)
        }
    }

}
