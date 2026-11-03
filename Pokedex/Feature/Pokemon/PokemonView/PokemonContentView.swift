//
//  PokemonContentView.swift
//  
//
//  Created by Daniel Byon on 11/4/22.
//

import Dependencies
import PokedexUI
import SwiftUI

struct PokemonContentView: View {

    @AppStorage(.shouldUseMetersForHeight, store: .appGroup) private var shouldUseMetersForHeight = false
    @AppStorage(.pokemonDetailOrdering, store: .appGroup) private var storedOrdering: Data?
    @Binding var currentFormIndex: Int
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Dependency(\.userDataDataStore) var dataStore
    @ObservedObject var viewModel: PokemonContentViewModel

    private var pokemon: PokemonDetail { viewModel.pokemon }
    private var pokedex: Pokedex { viewModel.pokedex }

    private var currentForm: PokemonDetailForm { pokemon.forms[currentFormIndex] }

    private var sectionOrder: [PokemonDetailSection] {
        guard let storedOrdering = storedOrdering,
              let sectionOrder = try? JSONDecoder().decode([PokemonDetailSection].self, from: storedOrdering) else {
            return PokemonDetailSection.allCases
        }
        return sectionOrder
    }

    private let verticalPadding: CGFloat = 4.0

    var body: some View {
        List {
            header()
            sections()
        }
        .listStyle(.grouped)
        .navigationTitle(pokemon.name)
        // TODO: Figure out why changes aren't reflected in PokemonList
//        .toolbar {
//            ToolbarItemGroup(placement: .navigationBarTrailing) {
//                Menu {
//                    makeCaughtPokemonButton()
//                } label: {
//                    Image(systemName: "line.3.horizontal.circle")
//                }
//            }
//        }
        .onAppear {
            viewModel.dataStore = dataStore
        }
    }

    @ViewBuilder
    private func header() -> some View {
        let image = PokemonImage(form: currentForm)

        let metadata = VStack(alignment: .leading, spacing: 16.0) {
            VStack(alignment: .leading) {
                Text("#\(pokemon.pokedexNumberString(for: pokedex)) \(pokemon.name)")
                    .monospacedLargeTitle()

                Text("\(currentForm.species) Pokémon")
                    .monospacedBody()
            }

            HStack {
                Badge(pokemonType: currentForm.primaryType)
                if let secondaryType = currentForm.secondaryType {
                    Badge(pokemonType: secondaryType)
                }
            }
        }

#if targetEnvironment(macCatalyst)
        Section {
            HStack(spacing: 16.0) {
                image
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                metadata
                Spacer()
            }
        }
        .padding(.vertical, verticalPadding)
#else
        if horizontalSizeClass == .compact {
            Section {
                HStack {
                    Spacer()
                    image
                        .frame(idealWidth: 300, idealHeight: 300)
                    Spacer()
                }
                metadata
            }
            .padding(.vertical, verticalPadding)
        } else {
            Section {
                HStack(spacing: 16.0) {
                    image
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                    metadata
                    Spacer()
                }
            }
            .padding(.vertical, verticalPadding)
        }
#endif
    }

    @ViewBuilder
    private func sections() -> some View {
        ForEach(sectionOrder, id: \.self) { section in
            view(for: section)
        }
    }

    @ViewBuilder
    private func view(for section: PokemonDetailSection) -> some View {
        switch section {
        case .forms:
            if pokemon.hasAlternateForms {
                Section {
                    VStack(alignment: .leading) {
                        PokemonFormPicker(
                            forms: pokemon.forms,
                            backgroundColor: Color(currentForm.color.uiColor),
                            currentIndex: $currentFormIndex
                        )
                        Text(currentForm.name)
                            .monospacedCaption()
                            .animation(.none, value: currentForm.name)
                    }
                } header: {
                    SectionHeader("Forms")
                }
                .padding(.vertical, verticalPadding)
            }
        case .pokedexEntry:
            Section {
                DescriptionCell(text: currentForm.pokedexEntry)
            } header: {
                SectionHeader("Pokédex Entry")
            }
            .padding(.vertical, verticalPadding)
        case .abilities:
            if currentForm.hasAbilities {
                Section {
                    PokemonAbilities(form: currentForm, pokedex: pokedex)
                        .padding(.vertical, verticalPadding)
                } header: {
                    SectionHeader("Abilities")
                }
            }
        case .typeEffectiveness:
            Section {
                PokemonTypeEffectiveness(primaryType: currentForm.primaryType, secondaryType: currentForm.secondaryType, kind: .defense, game: currentForm.game)
            } header: {
                SectionHeader("Type Effectiveness")
            }
            .padding(.vertical, verticalPadding)
        case .moves:
            Section {
                NavigationLink(value: Route.content(.learnset(currentForm, game: currentForm.game, learnsetType: .level))) {
                    Value1Cell(text: "By Level")
                }
                NavigationLink(value: Route.content(.learnset(currentForm, game: currentForm.game, learnsetType: .machine))) {
                    Value1Cell(text: "By Machine")
                }
                if currentForm.game.datasetFeatures.showsBreedingLearnsets {
                    NavigationLink(value: Route.content(.learnset(currentForm, game: currentForm.game, learnsetType: .breeding))) {
                        Value1Cell(text: "By Breeding")
                    }
                }
                if currentForm.game.datasetFeatures.showsTutoringLearnsets {
                    NavigationLink(value: Route.content(.learnset(currentForm, game: currentForm.game, learnsetType: .tutoring))) {
                        Value1Cell(text: "By Tutoring")
                    }
                }
            } header: {
                SectionHeader("Moves")
            }
            .padding(.vertical, verticalPadding)
        case .evolutions:
            if let evolutions = currentForm.evolutions,
               !evolutions.isEmpty {
                Section {
                    PokemonEvolutions(evolutions: evolutions)
                } header: {
                    SectionHeader("Evolutions")
                }
                .padding(.vertical, verticalPadding)
            }
        case .locations:
            Section {
                NavigationLink(value: Route.content(.pokemonLocations(currentForm))) {
                    Text("View Locations")
                        .monospacedBody()
                }
            } header: {
                SectionHeader("Locations")
            }
        case .baseStats:
            Section {
                PokemonBaseStats(stats: currentForm.baseStats)
            } header: {
                SectionHeader("Base Stats")
            }
            .padding(.vertical, verticalPadding)
        case .evYield:
            Section {
                PokemonEVYield(evYield: currentForm.evYield)
            } header: {
                SectionHeader("EV Yield")
            }
            .padding(.vertical, verticalPadding)
        case .pokedexNumbers:
            Section {
                PokemonPokedexNumbers(pokedexNumbers: pokemon.pokedexNumbers, game: pokemon.game)
            } header: {
                SectionHeader("Pokédex Numbers")
            }
            .padding(.vertical, verticalPadding)
        case .basicInfo:
            Section {
                PokemonBasicInfo(pokemon: pokemon, pokemonForm: currentForm)
            } header: {
                SectionHeader("Basic Info")
            }
            .padding(.vertical, verticalPadding)
        case .externalLinks:
            Section {
                PokemonExternalLinks(pokemon: pokemon)
            } header: {
                SectionHeader("External Links")
            } footer: {
                ExternalLinksDisclaimer()
            }
        }
    }

    private func makeCaughtPokemonButton() -> some View {
        let isCaught = viewModel.isCaught
        return Button {
            if isCaught {
                viewModel.markUncaught()
            } else {
                viewModel.markCaught()
            }
        } label: {
            Label(
                isCaught ? "Mark Uncaught" : "Mark Caught",
                systemImage: isCaught ? "checkmark.circle.fill" : "checkmark.circle"
            )
        }
    }

}
