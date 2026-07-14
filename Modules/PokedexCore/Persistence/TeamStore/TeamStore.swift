//
//  TeamStore.swift
//
//
//  Created by Daniel Byon on 10/27/22.
//

import Combine
import Foundation

public protocol TeamStore: AnyObject {

    typealias Teams = [Game: [Team]]

    @MainActor var teams: AnyPublisher<Teams, Never> { get }

    @MainActor subscript(game: Game) -> [Team] { get set }

    @MainActor func getTeams(forGame game: Game) -> [Team]
    @MainActor func setTeams(_ teams: [Team], forGame game: Game)
    @MainActor func saveTeam(_ team: Team, forGame game: Game)
    @MainActor func removeTeam(_ team: Team, forGame game: Game)
    @MainActor func flushPendingWrites()
}

/// Main-actor cache for teams with serialized, debounced app-group persistence.
///
/// Cache state never leaves the main actor. Each mutation submits an immutable
/// value snapshot to `TeamPersistenceWriter`, which owns all background work.
public final class DefaultTeamStore: TeamStore {

    @MainActor public var teams: AnyPublisher<Teams, Never> {
        cacheSubject.eraseToAnyPublisher()
    }

    @MainActor private var cache: Teams { cacheSubject.value }
    @MainActor private let cacheSubject: CurrentValueSubject<Teams, Never>
    private let persistenceWriter: TeamPersistenceWriter

    @MainActor
    public init(
        storage: TeamStorage,
        notificationCenter: NotificationCenter = .default,
        debounceInterval: TimeInterval = 0.2
    ) {
        cacheSubject = .init(Self.loadCache(from: storage))
        persistenceWriter = TeamPersistenceWriter(
            storage: storage,
            notificationCenter: notificationCenter,
            debounceInterval: debounceInterval
        )
    }

    deinit {
        persistenceWriter.shutdown()
    }

    @MainActor
    public subscript(game: Game) -> [Team] {
        get { getTeams(forGame: game) }
        set { setTeams(newValue, forGame: game) }
    }

    @MainActor
    public func getTeams(forGame game: Game) -> [Team] {
        cache[game] ?? []
    }

    @MainActor
    public func setTeams(_ teams: [Team], forGame game: Game) {
        var snapshot = cache
        snapshot[game] = teams
        publishAndPersist(snapshot)
    }

    @MainActor
    public func saveTeam(_ team: Team, forGame game: Game) {
        var snapshot = cache
        var teams = snapshot[game] ?? []
        if let index = teams.firstIndex(where: { $0.internalID == team.internalID }) {
            teams[index] = team
        } else {
            teams.append(team)
        }
        snapshot[game] = teams
        publishAndPersist(snapshot)
    }

    @MainActor
    public func removeTeam(_ team: Team, forGame game: Game) {
        var snapshot = cache
        guard var teams = snapshot[game],
              let index = teams.firstIndex(where: { $0.internalID == team.internalID }) else {
            return
        }
        teams.remove(at: index)
        snapshot[game] = teams
        publishAndPersist(snapshot)
    }

    /// Persists the latest submitted snapshot before returning.
    ///
    /// App lifecycle code calls this API when entering the background. Object
    /// deinitialization deliberately does not provide a persistence guarantee.
    @MainActor
    public func flushPendingWrites() {
        persistenceWriter.flushPendingWrites()
    }

    @MainActor
    private func publishAndPersist(_ snapshot: Teams) {
        cacheSubject.value = snapshot
        persistenceWriter.submit(snapshot)
    }

    static func loadCache(from storage: TeamStorage) -> Teams {
        Game.allDatasets.reduce(into: [:]) { teamMap, game in
            guard let teams = storage.loadTeams(forGame: game) else { return }
            teamMap[game] = teams
        }
    }

    static func flushCache(_ snapshot: Teams, to storage: TeamStorage) {
        for (game, teams) in snapshot {
            storage.saveTeams(teams, forGame: game)
        }
    }
}

/// Serial owner for pending team snapshots and persistence work.
///
/// The writer never references `DefaultTeamStore`; scheduled work operates only
/// on an immutable snapshot and the writer's injected persistence dependencies.
final class TeamPersistenceWriter {

    /// Mutable state confined to `executor`.
    private final class State {
        var pendingSnapshot: TeamStore.Teams?
        var pendingWork: DispatchWorkItem?
        var generation = 0
        var isShutDown = false
    }

    private let executor = DispatchQueue(label: "com.danielbyon.pokedex.team-persistence", qos: .utility)
    private let executorKey = DispatchSpecificKey<UInt8>()
    private let storage: TeamStorage
    private let notificationCenter: NotificationCenter
    private let debounceInterval: TimeInterval
    private let state = State()

    init(
        storage: TeamStorage,
        notificationCenter: NotificationCenter,
        debounceInterval: TimeInterval
    ) {
        self.storage = storage
        self.notificationCenter = notificationCenter
        self.debounceInterval = debounceInterval
        executor.setSpecific(key: executorKey, value: 1)
    }

    deinit {
        shutdown()
    }

    func submit(_ snapshot: TeamStore.Teams) {
        executeSynchronously {
            guard !state.isShutDown else { return }
            state.pendingSnapshot = snapshot
            state.pendingWork?.cancel()
            state.generation += 1

            let generation = state.generation
            let state = state
            let storage = storage
            let notificationCenter = notificationCenter
            let work = DispatchWorkItem {
                guard !state.isShutDown,
                      state.generation == generation,
                      let snapshot = state.pendingSnapshot else {
                    return
                }
                state.pendingWork = nil
                state.pendingSnapshot = nil
                DefaultTeamStore.flushCache(snapshot, to: storage)
                notificationCenter.post(name: .teamsUpdated, object: nil)
            }
            state.pendingWork = work
            executor.asyncAfter(deadline: .now() + debounceInterval, execute: work)
        }
    }

    func flushPendingWrites() {
        executeSynchronously {
            guard !state.isShutDown, let snapshot = state.pendingSnapshot else { return }
            state.pendingWork?.cancel()
            state.pendingWork = nil
            state.pendingSnapshot = nil
            DefaultTeamStore.flushCache(snapshot, to: storage)
            notificationCenter.post(name: .teamsUpdated, object: nil)
        }
    }

    /// Cancels pending work without claiming that teardown persisted it.
    func shutdown() {
        executeSynchronously {
            guard !state.isShutDown else { return }
            state.isShutDown = true
            state.generation += 1
            state.pendingWork?.cancel()
            state.pendingWork = nil
            state.pendingSnapshot = nil
        }
    }

    private func executeSynchronously<T>(_ operation: () -> T) -> T {
        if DispatchQueue.getSpecific(key: executorKey) != nil {
            return operation()
        }
        return executor.sync(execute: operation)
    }
}
