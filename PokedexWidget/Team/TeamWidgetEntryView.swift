//
//  TeamWidgetEntryView.swift
//  PokedexWidgetExtension
//
//  Created by Daniel Byon on 12/8/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import WidgetKit
import SwiftUI

struct TeamWidgetEntryView : View {
    var entry: TeamProvider.Entry

    var body: some View {
        if let teamName = entry.teamName {
            VStack(alignment: .leading) {
                Text(teamName)
                    .monospacedHeadline()
                Spacer()
                LazyVGrid(columns: [.init(), .init()], alignment: .leading, spacing: 4.0) {
                    ForEach(0..<entry.teamMemberSpriteNames.count, id: \.self) { i in
                        HStack {
                            Sprite(entry.teamMemberSpriteNames[i], width: 32.0)
                            Text(entry.teamMemberNames[i])
                                .monospacedCaption()
                            Spacer()
                        }
                        .contentShape(Rectangle())
//                        .background(
//                            ContainerRelativeShape()
//                                .stroke(Color(AppConstants.tintColor), style: StrokeStyle(lineWidth: 1)))
                    }
                }
                .padding(4)
                .background(ContainerRelativeShape()
                                .fill(Color(UIColor.systemGray6)))
            }
            .padding()
            .edgesIgnoringSafeArea(.all)
            .widgetURL(URL(teamID: entry.teamID, game: entry.game))
        } else {
            Text("No team selected")
                .padding()
        }
    }
}

struct TeamWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        TeamWidgetEntryView(entry: TeamEntry(team: placeholderTeam, game: "sword"))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
//            .environment(\.sizeCategory, .extraExtraExtraLarge)
    }
}

private let placeholderTeam = Team(
    name: "My team",
    members: [
        makeTeamMember(withName: "Pikachu"),
        makeTeamMember(withName: "Bulbasaur"),
        makeTeamMember(withName: "Charmander"),
        makeTeamMember(withName: "Squirtle"),
        makeTeamMember(withName: "Clefairy"),
        makeTeamMember(withName: "Caterpie")
    ],
    internalID: .init()
)

private func makeTeamMember(withName name: String) -> TeamMember {
    TeamMember(
        pokemon: name,
        formName: name,
        nickname: name,
        level: 100,
        hp: .init(baseValue: 100, ev: 0, iv: 0),
        attack: .init(baseValue: 100, ev: 0, iv: 0),
        defense: .init(baseValue: 100, ev: 0, iv: 0),
        specialAttack: .init(baseValue: 100, ev: 0, iv: 0),
        specialDefense: .init(baseValue: 100, ev: 0, iv: 0),
        speed: .init(baseValue: 100, ev: 0, iv: 0),
        move1: nil,
        move2: nil,
        move3: nil,
        move4: nil,
        nature: "Calm",
        ability: nil,
        heldItem: nil,
        happiness: 0,
        isShiny: false,
        gender: .male,
        game: .sword,
        internalID: UUID())
}
