//
//  ContentView.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/11/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import AbilityFeature
import BattleAssistantFeature
import DualTypeFeature
import ItemFeature
import LocationFeature
import MachineFeature
import MoveFeature
import NatureFeature
import PokemonFeature
import SwiftUI
import TeamFeature
import TypeFeature

struct ContentView: View {

    @EnvironmentObject var settings: AppSettings
    @SceneStorage("navigationPath") private var navigationData: Data?
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @StateObject private var navigationStore = NavigationStore()
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
        NavigationStack(path: $navigationStore.path) {
            ScrollView {
                LazyVGrid(columns: Array(repeating: .init(spacing: spacing), count: numberOfColumns), spacing: spacing) {
                    Section {
                        contentButtons()
                    } header: {
                        header()
                    } footer: {
                        Divider()
                    }

                    Section {
                        settingsButtons()
                    } header: {
                        gameSelectorButton()
                    }
                }
                .padding()
            }
            .navigationTitle(AppConstants.appName)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .battleAssistant(let battleAssistant):
                    switch battleAssistant {
                    case .selectPokemon(let game):
                        SelectPokemonForm(game: game)
                    }
                case .content(let content):
                    switch content {
                    case .ability(let ability, let game, let pokedex):
                        AbilityView(ability: ability, game: game, pokedex: pokedex)
                    case .abilityPokemonForm(let pokemonForm, let pokedex):
                        PokemonView(abilityPokemonForm: pokemonForm, pokedex: pokedex)
                    case .evolutionPokemonForm(let pokemonForm, pokedex: let pokedex):
                        PokemonView(evolutionPokemonForm: pokemonForm, pokedex: pokedex)
                    case .item(let item):
                        ItemView(item: item)
                    case .learnset(let pokemonForm, let game, let learnsetType):
                        PokemonLearnsetView(form: pokemonForm, game: game, learnsetType: learnsetType)
                    case .learnsetPokemonForm(let pokemonForm):
                        PokemonView(learnsetPokemonForm: pokemonForm)
                    case .location(let location):
                        LocationView(location: location)
                    case .move(let move):
                        MoveView(move: move, viewFactory: ConcreteMoveViewFactory())
                    case let .pokemon(pokemon, pokedex, previousPokemonProvider, nextPokemonProvider):
                        PokemonView(
                            pokemon: pokemon,
                            pokedex: pokedex,
                            previousPokemonProvider: previousPokemonProvider,
                            nextPokemonProvider: nextPokemonProvider
                        )
                    case .pokemonDetailForm(let pokemonDetailForm, let pokedex):
                        PokemonView(pokemonDetailForm: pokemonDetailForm, pokedex: pokedex)
                    case .pokemonLocations(let pokemonDetailForm):
                        PokemonLocations(pokemonForm: pokemonDetailForm)
                    case .type(let type, let game):
                        TypeView(type: type, game: game, viewFactory: ConcreteTypeViewFactory())
                    }
                case .tab(let tab):
                    switch tab {
                    case .abilities:
                        AbilityList(game: settings.currentGame)
                    case .battleAssistant:
                        BattleAssistant(
                            game: settings.currentGame,
                            viewFactory: ConcreteBattleAssistantViewFactory()
                        )
                    case .dualType:
                        DualTypeChecker(
                            game: settings.currentGame,
                            viewFactory: ConcreteDualTypeCheckerViewFactory()
                        )
                    case .moves:
                        MoveList(game: settings.currentGame)
                    case .items:
                        ItemList(game: settings.currentGame)
                    case .locations:
                        LocationList(game: settings.currentGame)
                    case .machines:
                        MachineList(title: machineListTitle, game: settings.currentGame)
                    case .natures:
                        NatureList()
                    case .pokemon:
                        PokemonList(game: settings.currentGame)
                    case .teams:
                        TeamList(
                            game: settings.currentGame,
                            viewFactory: ConcreteTeamViewFactory()
                        )
                    case .types:
                        TypeList(game: settings.currentGame)
                    }
                case .url(let url):
                    SafariView(url: url)
                }
            }
            .sheet(isPresented: $sheetState.isShowing, content: sheetDestination)
            .onOpenURL(perform: handleURL)
        }
        .navigationStore(navigationStore)
        .task {
            if let navigationData {
                navigationStore.restore(from: navigationData)
            }

            for await _ in navigationStore.$path.values {
                navigationData = navigationStore.encoded()
            }
        }
    }

//    var body: some View {
//        NavigationSplitView(columnVisibility: $columnVisibility) {
//            NavigationStack(path: $navigationStore.path) {
//                ScrollView {
//                    LazyVGrid(columns: Array(repeating: .init(spacing: spacing), count: numberOfColumns), spacing: spacing) {
//                        Section(header: header(), footer: Divider()) {
//                            contentButtons()
//                        }
//
//                        Section(header: gameSelectorButton()) {
//                            settingsButtons()
//                        }
//                    }
//                    .padding()
//                }
//                .navigationTitle(AppConstants.appName)
//                .navigationBarTitleDisplayMode(.inline)
//                .navigationDestination(for: Route.self) { route in
//                    switch route {
//                    case .battleAssistant(let battleAssistant):
//                        switch battleAssistant {
//                        case .selectPokemon(let game):
//                            SelectPokemonForm(game: game)
//                        }
//                    case .content(let content):
//                        switch content {
//                        case .ability(let ability, let game, let pokedex):
//                            AbilityView(ability: ability, game: game, pokedex: pokedex)
//                        case .abilityPokemonForm(let pokemonForm, let pokedex):
//                            PokemonView(abilityPokemonForm: pokemonForm, pokedex: pokedex)
//                        case .evolutionPokemonForm(let pokemonForm, pokedex: let pokedex):
//                            PokemonView(evolutionPokemonForm: pokemonForm, pokedex: pokedex)
//                        case .item(let item):
//                            ItemView(item: item)
//                        case .learnset(let pokemonForm, let game, let learnsetType):
//                            PokemonLearnsetView(form: pokemonForm, game: game, learnsetType: learnsetType)
//                        case .learnsetPokemonForm(let pokemonForm):
//                            PokemonView(learnsetPokemonForm: pokemonForm)
//                        case .location(let location):
//                            LocationView(location: location)
//                        case .move(let move):
//                            MoveView(move: move, viewFactory: ConcreteMoveViewFactory())
//                        case .pokemon(let pokemon, let pokedex):
//                            PokemonView(pokemon: pokemon, pokedex: pokedex)
//                        case .pokemonDetailForm(let pokemonDetailForm, let pokedex):
//                            PokemonView(pokemonDetailForm: pokemonDetailForm, pokedex: pokedex)
//                        case .pokemonLocations(let pokemonDetailForm):
//                            Text(pokemonDetailForm.name)
//                        case .type(let type, let game):
//                            TypeView(type: type, game: game, viewFactory: ConcreteTypeViewFactory())
//                        }
//                    case .tab(let tab):
//                        switch tab {
//                        case .abilities:
//                            AbilityList(game: settings.currentGame)
//                        case .battleAssistant:
//                            BattleAssistant(
//                                game: settings.currentGame,
//                                viewFactory: ConcreteBattleAssistantViewFactory()
//                            )
//                        case .dualType:
//                            DualTypeChecker(
//                                game: settings.currentGame,
//                                viewFactory: ConcreteDualTypeCheckerViewFactory()
//                            )
//                        case .moves:
//                            MoveList(game: settings.currentGame)
//                        case .items:
//                            ItemList(game: settings.currentGame)
//                        case .locations:
//                            LocationList(game: settings.currentGame)
//                        case .machines:
//                            MachineList(title: machineListTitle, game: settings.currentGame)
//                        case .natures:
//                            NatureList()
//                        case .pokemon:
//                            PokemonList(game: settings.currentGame)
//                        case .teams:
//                            TeamList(
//                                game: settings.currentGame,
//                                viewFactory: ConcreteTeamViewFactory()
//                            )
//                        case .types:
//                            TypeList(game: settings.currentGame)
//                        }
//                    case .url(let url):
//                        SafariView(url: url)
//                    }
//                }
//                .sheet(isPresented: $sheetState.isShowing, content: sheetDestination)
//                .onOpenURL(perform: handleURL)
//            }
//        } detail: {
//            NavigationStack {
//                Text("Choose an item to get started")
//            }
//        }
//        .environmentObject(navigationStore)
//        .task {
//            if let navigationData {
//                navigationStore.restore(from: navigationData)
//            }
//
//            for await _ in navigationStore.$path.values {
//                navigationData = navigationStore.encoded()
//            }
//        }
//    }

    @ViewBuilder
    private func contentButtons() -> some View {
        Group {
            NavigationLink(value: Route.tab(.pokemon)) {
                BigColoredButton(title: "Pokémon", fillColor: AppColor.red.color)
            }
//            NavigationLink {
//                PokemonList(game: settings.currentGame)
//            } label: {
//                BigColoredButton(title: "Pokémon", fillColor: AppColor.red.color)
//            }
            .frame(minHeight: mediumButtonHeight)

            NavigationLink(value: Route.tab(.moves)) {
                BigColoredButton(title: "Moves", fillColor: AppColor.blue.color)
            }
//            NavigationLink {
//                MoveList(game: settings.currentGame)
//            } label: {
//                BigColoredButton(title: "Moves", fillColor: AppColor.blue.color)
//            }
            .frame(minHeight: mediumButtonHeight)

            NavigationLink(value: Route.tab(.locations)) {
                BigColoredButton(title: "Locations", fillColor: AppColor.orange.color)
            }
//            NavigationLink {
//                LocationList(game: settings.currentGame)
//            } label: {
//                BigColoredButton(title: "Locations", fillColor: AppColor.orange.color)
//            }
            .frame(minHeight: mediumButtonHeight)

            NavigationLink(value: Route.tab(.items)) {
                BigColoredButton(title: "Items", fillColor: AppColor.teal.color)
            }
//            NavigationLink {
//                ItemList(game: settings.currentGame)
//            } label: {
//                BigColoredButton(title: "Items", fillColor: AppColor.teal.color)
//            }
            .frame(minHeight: mediumButtonHeight)
        }

        if settings.currentGame.hasAbilities {
            NavigationLink(value: Route.tab(.abilities)) {
                BigColoredButton(title: "Abilities", textColor: .black, fillColor: normalItemColor)
            }
//            NavigationLink {
//                AbilityList(game: settings.currentGame)
//            } label: {
//                BigColoredButton(title: "Abilities", textColor: .black, fillColor: normalItemColor)
//            }
        }

        NavigationLink(value: Route.tab(.natures)) {
            BigColoredButton(title: "Natures", textColor: .black, fillColor: normalItemColor)
        }
//        NavigationLink {
//            NatureList()
//        } label: {
//            BigColoredButton(title: "Natures", textColor: .black, fillColor: normalItemColor)
//        }

        NavigationLink(value: Route.tab(.types)) {
            BigColoredButton(title: "Types", textColor: .black, fillColor: normalItemColor)
        }
//        NavigationLink {
//            TypeList(game: settings.currentGame)
//        } label: {
//            BigColoredButton(title: "Types", textColor: .black, fillColor: normalItemColor)
//        }

        if settings.currentGame.hasMachines {
            NavigationLink(value: Route.tab(.machines)) {
                BigColoredButton(title: machineListTitle, textColor: .black, fillColor: normalItemColor)
            }
//            NavigationLink {
//                MachineList(title: machineListTitle, game: settings.currentGame)
//            } label: {
//                BigColoredButton(title: machineListTitle, textColor: .black, fillColor: normalItemColor)
//            }
        }

        NavigationLink(value: Route.tab(.dualType)) {
            BigColoredButton(title: "Dual Type Checker", textColor: .black, fillColor: normalItemColor)
        }
//        NavigationLink {
//            DualTypeChecker(
//                game: settings.currentGame,
//                viewFactory: ConcreteDualTypeCheckerViewFactory()
//            )
//        } label: {
//            BigColoredButton(title: "Dual Type Checker", textColor: .black, fillColor: normalItemColor)
//        }

        NavigationLink(value: Route.tab(.battleAssistant)) {
            BigColoredButton(title: "Battle Assistant", textColor: .black, fillColor: normalItemColor)
        }
//        NavigationLink {
//            BattleAssistant(
//                game: settings.currentGame,
//                viewFactory: ConcreteBattleAssistantViewFactory()
//            )
//        } label: {
//            BigColoredButton(title: "Battle Assistant", textColor: .black, fillColor: normalItemColor)
//        }

        NavigationLink(value: Route.tab(.teams)) {
            BigColoredButton(title: "Teams", textColor: .black, fillColor: normalItemColor)
        }
//        NavigationLink {
//            TeamList(
//                game: settings.currentGame,
//                viewFactory: ConcreteTeamViewFactory()
//            )
//        } label: {
//            BigColoredButton(title: "Teams", textColor: .black, fillColor: normalItemColor)
//        }
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
            NavigationStack {
                GameSelector()
                    .injectDependencies()
            }
        case .settings:
            NavigationStack {
                Settings()
                    .injectDependencies()
            }
        case .store:
            NavigationStack {
                Store()
                    .injectDependencies()
            }
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
            navigationStore.path = .init([Route.tab(.pokemon)])
        case .teams:
            navigationStore.path = .init([Route.tab(.teams)])
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
