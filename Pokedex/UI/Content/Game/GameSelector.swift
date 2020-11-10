//
//  GameSelector.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/10/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct GameSelector: View {

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appContext: AppContext
    @EnvironmentObject var purchasedProductState: PurchasedProductState
    @State private var isShowingStore = false

    var body: some View {
        NavigationView {
            List {
                ForEach(Generation.allCases.reversed()) { generation in
                    Section(header: SectionHeader(generation.title)) {
                        ForEach(generation.games) { game in
                            GameSelectorCell(game: game, currentGame: self.appContext.currentGame).onTapGesture {
                                if self.allowsSelection(for: game) {
                                    self.appContext.currentGame = game
                                    self.presentationMode.wrappedValue.dismiss()
                                } else {
                                    self.isShowingStore.toggle()
                                }
                            }
                        }
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
                Store()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
            .injectDependencies()
    }
}

struct GameSelectorCell: View {
    
    let game: Game
    let currentGame: Game

    var body: some View {
        HStack {
            Image("BoxArt/\(game.rawValue)")
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
