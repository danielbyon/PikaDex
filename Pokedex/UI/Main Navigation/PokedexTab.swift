//
//  PokemonTab.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/17/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokedexTab: View {

    @EnvironmentObject var appContext: AppContext
    @State private var isShowingAbout = false
    @State private var isShowingGameSelector = false
    @State private var isShowingSettings = false
    @State private var isShowingStore = false
    @State private var selectedTab: Tab? = nil

    private var spacing: CGFloat { 16.0 }
    private var largeButtonHeight: CGFloat { 150.0 }
    private var mediumButtonHeight: CGFloat { 80 }
    private var smallButtonHeight: CGFloat { (largeButtonHeight - spacing) / 3.0 }
    private var normalItemColor: Color { AppColor.gray.color }
    private var machineListTitle: String {
        var titleComponents: [String] = []
        if appContext.currentGame.hasTMs {
            titleComponents.append("TMs")
        }
        if appContext.currentGame.hasHMs {
            titleComponents.append("HMs")
        }
        if appContext.currentGame.hasTRs {
            titleComponents.append("TRs")
        }
        guard !titleComponents.isEmpty else { return "Machines" }
        return titleComponents.joined(separator: " / ")
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: .init(spacing: spacing), count: 2), spacing: spacing) {
                    Section(header: header(), footer: Divider()) {
                        contentButtons()
                    }

                    Section(header: gameSelectorButton()) {
                        settingsButtons()
                    }
                }
                .padding()
            }
            .navigationTitle(AppConstants.appName)
            .navigationBarTitle(AppConstants.appName, displayMode: .inline)
            Text("Choose an item to get started")
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }

    @ViewBuilder
    private func contentButtons() -> some View {
        Group {
            NavigationLink(destination: FilterablePokemonList(), tag: .pokemon, selection: $selectedTab) {
                BigColoredButton(title: "Pokémon", fillColor: AppColor.red.color)
            }
            .isDetailLink(false)
            .frame(minHeight: mediumButtonHeight)

            NavigationLink(destination: MoveList(game: appContext.currentGame), tag: .moves, selection: $selectedTab) {
                BigColoredButton(title: "Moves", fillColor: AppColor.blue.color)
            }
            .isDetailLink(false)
            .frame(minHeight: mediumButtonHeight)

            NavigationLink(destination: LocationList(game: appContext.currentGame), tag: .locations, selection: $selectedTab) {
                BigColoredButton(title: "Locations", fillColor: AppColor.orange.color)
            }
            .isDetailLink(false)
            .frame(minHeight: mediumButtonHeight)

            NavigationLink(destination: ItemList(game: appContext.currentGame), tag: .items, selection: $selectedTab) {
                BigColoredButton(title: "Items", fillColor: AppColor.teal.color)
            }
            .isDetailLink(false)
            .frame(minHeight: mediumButtonHeight)
        }

        if appContext.currentGame.hasAbilities {
            NavigationLink(destination: AbilityList(game: appContext.currentGame), tag: .abilities, selection: $selectedTab) {
                BigColoredButton(title: "Abilities", textColor: .black, fillColor: normalItemColor)
            }
            .isDetailLink(false)
        }

        NavigationLink(destination: NatureList(), tag: .natures, selection: $selectedTab) {
            BigColoredButton(title: "Natures", textColor: .black, fillColor: normalItemColor)
        }

        NavigationLink(destination: TypeList(game: appContext.currentGame), tag: .types, selection: $selectedTab) {
            BigColoredButton(title: "Types", textColor: .black, fillColor: normalItemColor)
        }
        .isDetailLink(false)

        NavigationLink(destination: MachineList(title: machineListTitle, game: appContext.currentGame), tag: .machines, selection: $selectedTab) {
            BigColoredButton(title: machineListTitle, textColor: .black, fillColor: normalItemColor)
        }
        .isDetailLink(false)

        NavigationLink(destination: DualTypeDetail(game: appContext.currentGame), tag: .dualType, selection: $selectedTab) {
            BigColoredButton(title: "Dual Type Checker", textColor: .black, fillColor: normalItemColor)
        }

        NavigationLink(destination: BattleAssistant(), tag: .battleAssistant, selection: $selectedTab) {
            BigColoredButton(title: "Battle Assistant", textColor: .black, fillColor: normalItemColor)
        }

        NavigationLink(destination: TeamBuilder(viewModel: .init(game: appContext.currentGame)), tag: .teams, selection: $selectedTab) {
            BigColoredButton(title: "Teams", textColor: .black, fillColor: normalItemColor)
        }
    }

    @ViewBuilder
    private func settingsButtons() -> some View {
        Button(action: {
            self.isShowingStore.toggle()
        }) {
            BigColoredButton(icon: Image(systemName: "cart"), title: "Store", fillColor: Color(.systemBlue))
        }
        .sheet(isPresented: $isShowingStore) {
            Store()
                .injectDependencies()
        }

        Button(action: {
            self.isShowingSettings.toggle()
        }) {
            BigColoredButton(icon: Image(systemName: "gear"), title: "Settings", textColor: .black, fillColor: normalItemColor)
        }
        .sheet(isPresented: $isShowingSettings) {
            NavigationView {
                Settings()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .injectDependencies()
        }
    }

    private func header() -> some View {
        HStack {
            Text("Pokémon \(appContext.currentGame.title)")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }

    private func gameSelectorButton() -> some View {
        Button(action: {
            self.isShowingGameSelector.toggle()
        }) {
            BigColoredButton(icon: Image(systemName: "gamecontroller"), title: "Choose Game", fillColor: Color(.systemBlue))
        }
        .sheet(isPresented: $isShowingGameSelector) {
            GameSelector()
                .injectDependencies()
        }
    }

}

struct PokemonTab_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PokedexTab()
            PokedexTab()
                .environment(\.colorScheme, .dark)
        }
        .injectDependencies()
    }
}

private enum Tab: Hashable {
    case abilities
    case battleAssistant
    case dualType
    case moves
    case items
    case locations
    case machines
    case natures
    case pokemon
    case teams
    case types
}
