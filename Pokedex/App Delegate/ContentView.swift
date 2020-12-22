//
//  ContentView.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/11/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var settings: AppSettings
    @State private var selectedTab: Tab? = nil
    @StateObject private var sheetState = SheetState<ContentViewSheet>()

    private var spacing: CGFloat { 16.0 }
    private var largeButtonHeight: CGFloat { 150.0 }
    private var mediumButtonHeight: CGFloat { 80 }
    private var smallButtonHeight: CGFloat { (largeButtonHeight - spacing) / 3.0 }
    private var normalItemColor: Color { AppColor.gray.color }
    private var machineListTitle: String {
        var titleComponents: [String] = []
        if settings.currentGame.hasTMs {
            titleComponents.append("TMs")
        }
        if settings.currentGame.hasHMs {
            titleComponents.append("HMs")
        }
        if settings.currentGame.hasTRs {
            titleComponents.append("TRs")
        }
        guard !titleComponents.isEmpty else { return "Machines" }
        return titleComponents.joined(separator: " / ")
    }
    private var numberOfColumns: Int { 2 }

    private enum ContentViewSheet {
        case selectGame
        case settings
        case store
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: .init(spacing: spacing), count: numberOfColumns), spacing: spacing) {
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
        .sheet(isPresented: $sheetState.isShowing, content: sheetDestination)
        .onOpenURL(perform: handleURL)
    }

    @ViewBuilder
    private func contentButtons() -> some View {
        Group {
            NavigationLink(destination: FilterablePokemonList(game: settings.currentGame), tag: .pokemon, selection: $selectedTab) {
                BigColoredButton(title: "Pokémon", fillColor: AppColor.red.color)
            }
            .isDetailLink(false)
            .frame(minHeight: mediumButtonHeight)

            NavigationLink(destination: MoveList(game: settings.currentGame), tag: .moves, selection: $selectedTab) {
                BigColoredButton(title: "Moves", fillColor: AppColor.blue.color)
            }
            .isDetailLink(false)
            .frame(minHeight: mediumButtonHeight)

            NavigationLink(destination: LocationList(game: settings.currentGame), tag: .locations, selection: $selectedTab) {
                BigColoredButton(title: "Locations", fillColor: AppColor.orange.color)
            }
            .isDetailLink(false)
            .frame(minHeight: mediumButtonHeight)

            NavigationLink(destination: ItemList(game: settings.currentGame), tag: .items, selection: $selectedTab) {
                BigColoredButton(title: "Items", fillColor: AppColor.teal.color)
            }
            .isDetailLink(false)
            .frame(minHeight: mediumButtonHeight)
        }

        if settings.currentGame.hasAbilities {
            NavigationLink(destination: AbilityList(game: settings.currentGame), tag: .abilities, selection: $selectedTab) {
                BigColoredButton(title: "Abilities", textColor: .black, fillColor: normalItemColor)
            }
            .isDetailLink(false)
        }

        NavigationLink(destination: NatureList(), tag: .natures, selection: $selectedTab) {
            BigColoredButton(title: "Natures", textColor: .black, fillColor: normalItemColor)
        }

        NavigationLink(destination: TypeList(game: settings.currentGame), tag: .types, selection: $selectedTab) {
            BigColoredButton(title: "Types", textColor: .black, fillColor: normalItemColor)
        }
        .isDetailLink(false)

        NavigationLink(destination: MachineList(title: machineListTitle, game: settings.currentGame), tag: .machines, selection: $selectedTab) {
            BigColoredButton(title: machineListTitle, textColor: .black, fillColor: normalItemColor)
        }
        .isDetailLink(false)

        NavigationLink(destination: DualTypeDetail(game: settings.currentGame), tag: .dualType, selection: $selectedTab) {
            BigColoredButton(title: "Dual Type Checker", textColor: .black, fillColor: normalItemColor)
        }

        NavigationLink(destination: BattleAssistant(), tag: .battleAssistant, selection: $selectedTab) {
            BigColoredButton(title: "Battle Assistant", textColor: .black, fillColor: normalItemColor)
        }

        NavigationLink(destination: TeamBuilder(game: settings.currentGame).id(settings.currentGame), tag: .teams, selection: $selectedTab) {
            BigColoredButton(title: "Teams", textColor: .black, fillColor: normalItemColor)
        }
    }

    @ViewBuilder
    private func settingsButtons() -> some View {
        Button {
            sheetState.state = .store
        } label: {
            BigColoredButton(icon: Image(systemName: "cart"), title: "Store", fillColor: Color(.systemBlue))
        }

        Button {
            sheetState.state = .settings
        } label: {
            BigColoredButton(icon: Image(systemName: "gear"), title: "Settings", textColor: .black, fillColor: normalItemColor)
        }
    }

    private func header() -> some View {
        Text("Pokémon \(settings.currentGame.title)")
            .font(.largeTitle)
            .bold()
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func gameSelectorButton() -> some View {
        Button {
            sheetState.state = .selectGame
        } label: {
            BigColoredButton(icon: Image(systemName: "gamecontroller"), title: "Choose Game", fillColor: Color(.systemBlue))
        }
    }

    @ViewBuilder
    private func sheetDestination() -> some View {
        switch sheetState.state {
        case .selectGame:
            GameSelector()
                .injectDependencies()
        case .settings:
            NavigationView {
                Settings()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .injectDependencies()
        case .store:
            Store()
                .injectDependencies()
        case .none:
            EmptyView()
        }
    }

    private func handleURL(_ url: URL) {
        guard url.isDeepLink else {
            debugPrint("Unsupported URL: \(url)")
            return
        }

        if let game = url.game {
            settings.currentGame = game
        }

        switch url.supportedHost {
        case .pokemon:
            selectedTab = .pokemon
        case .teams:
            selectedTab = .teams
        default:
            debugPrint("Unsupported host: \(url)")
            break
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
                .environment(\.colorScheme, .dark)
        }
        .injectDependencies()
    }
}

private enum Tab: String, Hashable, Identifiable {

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

    var id: String { rawValue }

}

// MARK: Experimental
// Revisit for SwiftUI 3 to see if TabView is fixed
//private extension PokedexTab {
//
//    var body2: some View {
//        TabView(selection: $selectedTab2) {
//            Group {
//                pokemonTab()
//
//                movesTab()
//
//                locationsTab()
//
//                itemsTab()
//
//                if settings.currentGame.hasAbilities {
//                    abilitiesTab()
//                }
//
//                naturesTab()
//
//                typesTab()
//
//                machinesTab()
//
//                dualTypeCheckerTab()
//
//                battleAssistantTab()
//            }
//
//            teamBuilderTab()
//        }
//        .onOpenURL(perform: handleURL)
//    }
//
//    func pokemonTab() -> some View {
//        NavigationView {
//            FilterablePokemonList()
//            Text("Choose an item to get started")
//        }
//        .if(selectedTab2 == .pokemon) {
//            $0.tabItem { Label("Pokémon", systemImage: "book.fill") }
//        } else: {
//            $0.tabItem { Label("Pokémon", systemImage: "book") }
//        }
//        .tag(Tab.pokemon)
//    }
//
//    func movesTab() -> some View {
//        NavigationView {
//            MoveList(game: settings.currentGame)
//            Text("Choose an item to get started")
//        }
//        .tabItem { Label("Moves", systemImage: "chevron.right.2") }
//        .tag(Tab.moves)
//    }
//
//    func locationsTab() -> some View {
//        NavigationView {
//            LocationList(game: settings.currentGame)
//            Text("Choose an item to get started")
//        }
//        .tabItem { Label("Locations", systemImage: "location") }
//        .tag(Tab.locations)
//    }
//
//    func itemsTab() -> some View {
//        NavigationView {
//            ItemList(game: settings.currentGame)
//            Text("Choose an item to get started")
//        }
//        .tabItem { Label("Items", systemImage: "pills") }
//        .tag(Tab.items)
//    }
//
//    func abilitiesTab() -> some View {
//        NavigationView {
//            AbilityList(game: settings.currentGame)
//            Text("Choose an item to get started")
//        }
//        .tabItem { Label("Abilities", systemImage: "bolt.horizontal") }
//        .tag(Tab.abilities)
//    }
//
//    func naturesTab() -> some View {
//        NavigationView {
//            NatureList()
//        }
//        .navigationViewStyle(StackNavigationViewStyle())
//        .tabItem { Label("Natures", systemImage: "leaf") }
//        .tag(Tab.natures)
//    }
//
//    func typesTab() -> some View {
//        NavigationView {
//            TypeList(game: settings.currentGame)
//            Text("Choose an item to get started")
//        }
//        .tabItem { Label("Types", systemImage: "doc") }
//        .tag(Tab.types)
//    }
//
//    func machinesTab() -> some View {
//        NavigationView {
//            MachineList(title: machineListTitle, game: settings.currentGame)
//            Text("Choose an item to get started")
//        }
//        .tabItem { Label(machineListTitle, systemImage: "opticaldisc") }
//        .tag(Tab.machines)
//    }
//
//    func dualTypeCheckerTab() -> some View {
//        NavigationView {
//            DualTypeDetail(game: settings.currentGame)
//        }
//        .navigationViewStyle(StackNavigationViewStyle())
//        .tabItem { Label("Dual Type Checker", systemImage: "person.2") }
//        .tag(Tab.dualType)
//    }
//
//    func battleAssistantTab() -> some View {
//        NavigationView {
//            BattleAssistant()
//        }
//        .navigationViewStyle(StackNavigationViewStyle())
//        .tabItem { Label("Battle Assistant", systemImage: "hammer") }
//        .tag(Tab.battleAssistant)
//    }
//
//    func teamBuilderTab() -> some View {
//        NavigationView {
//            TeamBuilder(viewModel: .init(game: settings.currentGame))
//        }
//        .navigationViewStyle(StackNavigationViewStyle())
//        .tabItem { Label("Teams", systemImage: "person.3") }
//        .tag(Tab.teams)
//    }
//
//}
