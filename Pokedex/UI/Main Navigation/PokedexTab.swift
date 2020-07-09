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
    @State private var isShowingNatures = false
    @State private var isShowingSettings = false
    @State private var isShowingStore = false
    @State private var selectedTab: Tab? = nil

    private var spacing: CGFloat { 16.0 }
    private var largeButtonHeight: CGFloat { 150.0 }
    private var mediumButtonHeight: CGFloat { 80 }
    private var smallButtonHeight: CGFloat { (largeButtonHeight - spacing) / 3.0 }
    private var normalItemColor: UIColor { AppColor.gray.uiColor }
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
    private var naturesButton: some View {
        Button(action: {
            self.isShowingNatures.toggle()
        }) {
            BigColoredButton(title: "Natures", textColor: .black, fillColor: normalItemColor)
        }
        .sheet(isPresented: $isShowingNatures) {
            NavigationView {
                NatureList()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .injectDependencies()
        }
    }
    private var typesButton: some View {
        NavigationLink(destination: TypeList(game: appContext.currentGame)
            .injectDependencies(), tag: .types, selection: $selectedTab) {
                BigColoredButton(title: "Types", textColor: .black, fillColor: normalItemColor)
        }
        .isDetailLink(false)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                makeTabs()
                    .padding()
            }
            .navigationBarTitle(Text(AppConstants.appName), displayMode: .inline)
            Text("Choose an item to get started")
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }

    private func makeTabs() -> some View {
            VStack(alignment: .leading, spacing: spacing) {
                Text("Pokémon \(appContext.currentGame.title)")
                    .multilineTextAlignment(.leading)
                    .font(Font.largeTitle.bold())
                    .fixedSize(horizontal: false, vertical: true)

                Group {
                    NavigationLink(destination: FilterablePokemonList()
                        .injectDependencies(), tag: .pokemon, selection: $selectedTab) {
                            BigColoredButton(title: "Pokémon", fillColor: AppColor.red.uiColor)
                    }
                    .isDetailLink(false)
                    .frame(minHeight: mediumButtonHeight)

                    NavigationLink(destination: MoveList(game: appContext.currentGame)
                        .injectDependencies(), tag: .moves, selection: $selectedTab) {
                            BigColoredButton(title: "Moves", fillColor: AppColor.blue.uiColor)
                    }
                    .isDetailLink(false)
                    .frame(minHeight: mediumButtonHeight)

                    NavigationLink(destination: LocationList(game: appContext.currentGame)
                        .injectDependencies(), tag: .locations, selection: $selectedTab) {
                            BigColoredButton(title: "Locations", fillColor: AppColor.orange.uiColor)
                    }
                    .isDetailLink(false)
                    .frame(minHeight: mediumButtonHeight)

                    NavigationLink(destination: ItemList(game: appContext.currentGame)
                        .injectDependencies(), tag: .items, selection: $selectedTab) {
                            BigColoredButton(title: "Items", fillColor: AppColor.teal.uiColor)
                    }
                    .isDetailLink(false)
                    .frame(minHeight: mediumButtonHeight)

                    if appContext.currentGame.hasAbilities {
                        NavigationLink(destination: AbilityList(game: appContext.currentGame)
                            .injectDependencies(), tag: .abilities, selection: $selectedTab) {
                                BigColoredButton(title: "Abilities", textColor: .black, fillColor: normalItemColor)
                        }
                        .isDetailLink(false)

                        naturesButton

                        typesButton
                    } else {
                        naturesButton
                        typesButton
                    }

                    NavigationLink(destination: MachineList(title: machineListTitle, game: appContext.currentGame)
                        .injectDependencies(), tag: .machines, selection: $selectedTab) {
                            BigColoredButton(title: machineListTitle, textColor: .black, fillColor: normalItemColor)
                    }
                    .isDetailLink(false)

                    NavigationLink(destination: DualTypeDetail(game: appContext.currentGame)
                        .injectDependencies(), tag: .dualType, selection: $selectedTab) {
                            BigColoredButton(title: "Dual Type Checker", textColor: .black, fillColor: normalItemColor)
                    }

                    NavigationLink(destination: BattleAssistant()
                        .injectDependencies(), tag: .battleAssistant, selection: $selectedTab) {
                            BigColoredButton(title: "Battle Assistant", textColor: .black, fillColor: normalItemColor)
                    }

                    NavigationLink(destination: TeamBuilder(viewModel: .init(game: appContext.currentGame))
                        .injectDependencies(), tag: .teams, selection: $selectedTab) {
                            BigColoredButton(title: "Teams", textColor: .black, fillColor: normalItemColor)
                    }
                }

                Divider()

                Button(action: {
                    self.isShowingGameSelector.toggle()
                }) {
                    BigColoredButton(icon: Image(systemName: "gamecontroller"), title: "Choose Game", fillColor: .systemBlue)
                }
                .sheet(isPresented: $isShowingGameSelector) {
                    GameSelector()
                        .injectDependencies()
                }

                Button(action: {
                    self.isShowingStore.toggle()
                }) {
                    BigColoredButton(icon: Image(systemName: "cart"), title: "Store", fillColor: .systemBlue)
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
                    Settings()
                        .injectDependencies()
                }
            }
    }

}

struct PokemonTab_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PokedexTab()
                .injectDependencies()
//            PokedexTab()
//                .environment(\.colorScheme, .dark)
//                .injectDependencies()
        }
    }
}

private enum Tab {
    case abilities
    case battleAssistant
    case dualType
    case moves
    case items
    case locations
    case machines
    case pokemon
    case teams
    case types
}
