//
//  GameSelector.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/10/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import Dependencies
import PokedexUI
import SwiftUI

struct GameSelector: View {

    @Environment(\.presentationMode) var presentationMode
    @Dependency(\.appSettings) var settings
    @Dependency(\.purchasedProductState) var purchasedProductState
    @State private var isShowingStore = false

    var body: some View {
        List {
            Section {
                gameRow(.national)
            } header: {
                SectionHeader(Game.national.title)
            }

            ForEach(Generation.releasedCasesLatestFirst) { generation in
                Section {
                    ForEach(generation.games) { game in
                        gameRow(game)
                    }
                } header: {
                    SectionHeader(generation.title)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Choose Game")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                DoneButton(action: dismiss)
            }
        }
        .sheet(isPresented: $isShowingStore) {
            NavigationStack {
                Store()
            }
            .colorSchemeModifier()
        }
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    private func gameRow(_ game: Game) -> some View {
        GameSelectorCell(game: game, currentGame: settings.currentGame)
            .onTapGesture {
                if allowsSelection(for: game) {
                    settings.currentGame = game
                    presentationMode.wrappedValue.dismiss()
                } else {
                    isShowingStore.toggle()
                }
            }
    }

    private func allowsSelection(for game: Game) -> Bool {
        // Sword/Shield are always free
        [Game.sword, .shield].contains(game) || purchasedProductState.hasPurchasedGame(game)
    }

}

struct GameSelector_Previews: PreviewProvider {
    static var previews: some View {
        PreviewDependencyRoot {
            GameSelector()
        }
    }
}

struct GameSelectorCell: View {
    
    let game: Game
    let currentGame: Game

    var body: some View {
        HStack {
            Image("BoxArt/\(game.rawValue)", bundle: .resources)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 60.0, height: 60.0)
            Text(game.title)
                .monospacedHeadline()
            Spacer()
            if game == currentGame {
                Image(systemName: "checkmark")
            }
        }
        .contentShape(Rectangle())
        .foregroundColor(.primary)
    }

}
