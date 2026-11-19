import Combine
import Dependencies
import Foundation
import PokedexCore
import XCTest
@testable import PikaDex

@MainActor
final class TeamNavigationRouteIdentityTests: XCTestCase {

    func testTeamRouteIdentityUsesGameAndSavedTeamUUID() {
        let teamID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let otherTeamID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        let teamStore = RecordingTeamStore()

        withDependencies {
            $0.teamStore = teamStore
        } operation: {
            let originalViewModel = TeamViewModel(
                team: Team(name: "Original", internalID: teamID),
                game: .sword
            )
            let originalRoute = Route.content(.team(
                game: .sword,
                teamID: teamID,
                viewModel: originalViewModel
            ))
            let originalHash = originalRoute.hashValue
            let routes: Set<Route> = [originalRoute]

            let recreatedViewModel = TeamViewModel(
                team: Team(
                    name: "Recreated with different contents",
                    members: [
                        makeTeamMember(
                            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
                            game: .sword,
                            nickname: "Changed"
                        )
                    ],
                    internalID: teamID
                ),
                game: .sword
            )
            let recreatedRoute = Route.content(.team(
                game: .sword,
                teamID: teamID,
                viewModel: recreatedViewModel
            ))

            XCTAssertEqual(originalRoute, recreatedRoute)
            XCTAssertEqual(originalRoute.hashValue, recreatedRoute.hashValue)
            XCTAssertTrue(routes.contains(recreatedRoute))

            originalViewModel.team.name = "Edited after navigation"
            originalViewModel.team.members.append(
                makeTeamMember(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
                    game: .sword,
                    nickname: "Added after navigation"
                )
            )

            XCTAssertEqual(originalRoute.hashValue, originalHash)
            XCTAssertEqual(originalRoute, recreatedRoute)
            XCTAssertEqual(originalRoute.hashValue, recreatedRoute.hashValue)
            XCTAssertTrue(routes.contains(recreatedRoute))
            XCTAssertTrue(routes.contains(originalRoute))
            XCTAssertEqual(routes.count, 1)
            guard case let .content(.team(_, _, destination)) = originalRoute else {
                XCTFail("The team route should retain its team view model")
                return
            }
            XCTAssertTrue(destination === originalViewModel)
            XCTAssertEqual(destination.team.name, "Edited after navigation")

            let otherGameViewModel = TeamViewModel(
                team: Team(name: "Same UUID in another game", internalID: teamID),
                game: .shield
            )
            let otherGameRoute = Route.content(.team(
                game: .shield,
                teamID: teamID,
                viewModel: otherGameViewModel
            ))
            XCTAssertNotEqual(originalRoute, otherGameRoute)

            let otherTeamViewModel = TeamViewModel(
                team: Team(name: "Different team", internalID: otherTeamID),
                game: .sword
            )
            let otherTeamRoute = Route.content(.team(
                game: .sword,
                teamID: otherTeamID,
                viewModel: otherTeamViewModel
            ))
            XCTAssertNotEqual(originalRoute, otherTeamRoute)
            XCTAssertEqual(Set([originalRoute, otherGameRoute, otherTeamRoute]).count, 3)
        }
    }

    func testTeamMemberRouteIdentityAndLiveEditorPayload() async {
        let teamID = UUID(uuidString: "00000000-0000-0000-0000-000000000011")!
        let otherTeamID = UUID(uuidString: "00000000-0000-0000-0000-000000000012")!
        let memberID = UUID(uuidString: "00000000-0000-0000-0000-000000000013")!
        let otherMemberID = UUID(uuidString: "00000000-0000-0000-0000-000000000014")!
        let editedNickname = "Edited after navigation"
        let teamStore = RecordingTeamStore()
        let memberEditSaved = expectation(description: "The member edit is published to the team store")
        teamStore.onSave = { savedTeam, game in
            guard game == .sword,
                  savedTeam.internalID == teamID,
                  savedTeam.members.first(where: { $0.internalID == memberID })?.nickname == editedNickname else {
                return
            }
            memberEditSaved.fulfill()
        }

        await withDependencies {
            $0.teamStore = teamStore
        } operation: {
            let originalMember = makeTeamMember(id: memberID, game: .sword, nickname: "Original")
            let team = Team(name: "Party", members: [originalMember], internalID: teamID)
            let originalViewModel = TeamMemberViewModel(
                teamMember: originalMember,
                team: team
            )
            let originalRoute = Route.content(.teamMember(
                game: .sword,
                teamID: teamID,
                memberID: memberID,
                viewModel: originalViewModel
            ))
            let originalHash = originalRoute.hashValue
            let routes: Set<Route> = [originalRoute]

            let recreatedViewModel = TeamMemberViewModel(
                teamMember: makeTeamMember(id: memberID, game: .sword, nickname: "Recreated"),
                team: Team(name: "Edited party", internalID: teamID)
            )
            let recreatedRoute = Route.content(.teamMember(
                game: .sword,
                teamID: teamID,
                memberID: memberID,
                viewModel: recreatedViewModel
            ))

            XCTAssertEqual(originalRoute, recreatedRoute)
            XCTAssertEqual(originalRoute.hashValue, recreatedRoute.hashValue)
            XCTAssertTrue(routes.contains(recreatedRoute))

            originalViewModel.teamMember.nickname = editedNickname
            await fulfillment(of: [memberEditSaved], timeout: 2)

            XCTAssertEqual(originalRoute.hashValue, originalHash)
            XCTAssertEqual(originalRoute, recreatedRoute)
            XCTAssertEqual(originalRoute.hashValue, recreatedRoute.hashValue)
            XCTAssertTrue(routes.contains(recreatedRoute))
            XCTAssertTrue(routes.contains(originalRoute))
            XCTAssertEqual(routes.count, 1)
            guard case let .content(.teamMember(_, _, _, destination)) = originalRoute else {
                XCTFail("The team-member route should retain its editor view model")
                return
            }
            XCTAssertTrue(destination === originalViewModel)
            XCTAssertEqual(destination.teamMember.nickname, editedNickname)

            let otherMemberViewModel = TeamMemberViewModel(
                teamMember: makeTeamMember(id: otherMemberID, game: .sword, nickname: "Other member"),
                team: team
            )
            let otherMemberRoute = Route.content(.teamMember(
                game: .sword,
                teamID: teamID,
                memberID: otherMemberID,
                viewModel: otherMemberViewModel
            ))
            XCTAssertNotEqual(originalRoute, otherMemberRoute)

            let otherTeamMemberViewModel = TeamMemberViewModel(
                teamMember: makeTeamMember(id: memberID, game: .sword, nickname: "Other team"),
                team: Team(name: "Other party", internalID: otherTeamID)
            )
            let otherTeamRoute = Route.content(.teamMember(
                game: .sword,
                teamID: otherTeamID,
                memberID: memberID,
                viewModel: otherTeamMemberViewModel
            ))
            XCTAssertNotEqual(originalRoute, otherTeamRoute)

            let otherGameMemberViewModel = TeamMemberViewModel(
                teamMember: makeTeamMember(id: memberID, game: .shield, nickname: "Other game"),
                team: Team(name: "Other game party", internalID: teamID)
            )
            let otherGameRoute = Route.content(.teamMember(
                game: .shield,
                teamID: teamID,
                memberID: memberID,
                viewModel: otherGameMemberViewModel
            ))
            XCTAssertNotEqual(originalRoute, otherGameRoute)

            let teamViewModel = TeamViewModel(team: team, game: .sword)
            let teamRoute = Route.content(.team(
                game: .sword,
                teamID: teamID,
                viewModel: teamViewModel
            ))
            XCTAssertNotEqual(originalRoute, teamRoute)
            XCTAssertEqual(
                Set([originalRoute, otherMemberRoute, otherTeamRoute, otherGameRoute, teamRoute]).count,
                5
            )

            let updatedTeam = teamStore.getTeams(forGame: .sword).first { $0.internalID == teamID }
            let updatedMember = updatedTeam?.members.first { $0.internalID == memberID }
            XCTAssertEqual(updatedMember?.nickname, editedNickname)
        }
    }

    func testTeamModelConformancesPreserveEqualityAndHashing() {
        let teamID = UUID(uuidString: "00000000-0000-0000-0000-000000000021")!
        let memberID = UUID(uuidString: "00000000-0000-0000-0000-000000000022")!
        let member = makeTeamMember(id: memberID, game: .sword, nickname: "Pika")
        let team = Team(name: "Party", members: [member], internalID: teamID)

        withDependencies {
            $0.teamStore = RecordingTeamStore()
        } operation: {
            let firstTeamViewModel = TeamViewModel(team: team, game: .sword)
            let secondTeamViewModel = TeamViewModel(team: team, game: .sword)

            XCTAssertEqual(firstTeamViewModel, secondTeamViewModel)
            XCTAssertEqual(firstTeamViewModel.hashValue, secondTeamViewModel.hashValue)
            XCTAssertEqual(Set([firstTeamViewModel, secondTeamViewModel]).count, 1)

            let firstMemberViewModel = TeamMemberViewModel(teamMember: member, team: team)
            let secondMemberViewModel = TeamMemberViewModel(teamMember: member, team: team)

            XCTAssertEqual(firstMemberViewModel, secondMemberViewModel)
            XCTAssertEqual(firstMemberViewModel.hashValue, secondMemberViewModel.hashValue)
            XCTAssertEqual(Set([firstMemberViewModel, secondMemberViewModel]).count, 1)

            let firstSection = TeamListViewModel.Section(game: .sword, teams: [firstTeamViewModel])
            let secondSection = TeamListViewModel.Section(game: .sword, teams: [secondTeamViewModel])

            XCTAssertEqual(firstSection, secondSection)
            XCTAssertEqual(firstSection.hashValue, secondSection.hashValue)
            XCTAssertEqual(Set([firstSection, secondSection]).count, 1)
        }
    }

}

private func makeTeamMember(id: UUID, game: Game, nickname: String) -> TeamMember {
    let stat = TeamMember.Stat(baseValue: 1, ev: 0, iv: 0)
    return TeamMember(
        pokemon: "Pikachu",
        formName: "",
        nickname: nickname,
        level: 50,
        hp: stat,
        attack: stat,
        defense: stat,
        specialAttack: stat,
        specialDefense: stat,
        speed: stat,
        move1: nil,
        move2: nil,
        move3: nil,
        move4: nil,
        nature: nil,
        ability: nil,
        heldItem: nil,
        game: game,
        internalID: id
    )
}

@MainActor
private final class RecordingTeamStore: TeamStore {

    private var teamsByGame: TeamStore.Teams = [:]
    private let subject = CurrentValueSubject<TeamStore.Teams, Never>([:])
    var onSave: (@MainActor (Team, Game) -> Void)?

    var teams: AnyPublisher<TeamStore.Teams, Never> {
        subject.eraseToAnyPublisher()
    }

    subscript(game: Game) -> [Team] {
        get { getTeams(forGame: game) }
        set { setTeams(newValue, forGame: game) }
    }

    func getTeams(forGame game: Game) -> [Team] {
        teamsByGame[game] ?? []
    }

    func setTeams(_ teams: [Team], forGame game: Game) {
        teamsByGame[game] = teams
        subject.send(teamsByGame)
    }

    func saveTeam(_ team: Team, forGame game: Game) {
        var teams = teamsByGame[game] ?? []
        if let index = teams.firstIndex(where: { $0.internalID == team.internalID }) {
            teams[index] = team
        } else {
            teams.append(team)
        }
        teamsByGame[game] = teams
        subject.send(teamsByGame)
        onSave?(team, game)
    }

    func removeTeam(_ team: Team, forGame game: Game) {
        var teams = teamsByGame[game] ?? []
        teams.removeAll { $0.internalID == team.internalID }
        setTeams(teams, forGame: game)
    }

    func flushPendingWrites() { }

}
