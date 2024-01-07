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
            ForEach(Generation.allCases.reversed()) { generation in
                Section {
                    ForEach(generation.games) { game in
                        GameSelectorCell(game: game, currentGame: self.settings.currentGame).onTapGesture {
                            if self.allowsSelection(for: game) {
                                self.settings.currentGame = game
                                self.presentationMode.wrappedValue.dismiss()
                            } else {
                                self.isShowingStore.toggle()
                            }
                        }
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
        }
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    private func allowsSelection(for game: Game) -> Bool {
        // Sword/Shield are always free
        [Game.sword, .shield].contains(game) || purchasedProductState.hasPurchasedGame(game)
    }

}

struct GameSelector_Previews: PreviewProvider {
    static var previews: some View {
        GameSelector()
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
