//
//  PokemonDetail.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/17/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI
import CoreData
import Convert

struct PokemonDetail: View {

    var pokemon: Pokemon {
        pokemonFetchRequest.first!
    }
    let game: Game
    let numberKeyPath: String

    @AppStorage("PokemonDetailOrdering") private var storedOrdering: Data?
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var currentFormIndex = 0
    @FetchRequest private var pokemonFetchRequest: FetchedResults<Pokemon>

    private var currentForm: PokemonForm { pokemon.forms[currentFormIndex] }
    private var primaryAbility: Ability { currentForm.primaryAbility }
    private var secondaryAbility: Ability? { currentForm.secondaryAbility }
    private var hiddenAbility: Ability? { currentForm.hiddenAbility }

    private var sectionOrder: [PokemonDetailSection] {
        guard let storedOrdering = storedOrdering,
              let sectionOrder = try? JSONDecoder().decode([PokemonDetailSection].self, from: storedOrdering) else { return PokemonDetailSection.allCases }
        return sectionOrder
    }

    private var generationIntroducedString: String { pokemon.generationIntroduced.title }
    private var catchRateString: String { "\(pokemon.catchRate)" }
    private var levelingRateString: String { pokemon.levelingRate.title }
    private var baseFriendshipString: String { "\(currentForm.baseFriendship)" }
    private var heightString: String {
        let shouldUseMetersForHeight = appSettings.shouldUseMetersForHeight
        let height = shouldUseMetersForHeight ? currentForm.heightInMeters : currentForm.heightInMeters.meter.to(.foot).value
        let isPlusHeight = height < 0
        let heightUnit = shouldUseMetersForHeight ? LengthFormatter.Unit.meter : .foot
        var heightString = LengthFormatter.height.string(fromValue: abs(height), unit: heightUnit)
        if isPlusHeight {
            heightString += "+" // Display "<number>+" when height < 0
        }
        return heightString
    }
    private var weightString: String {
        let shouldUseKilogramsForWeight = appSettings.shouldUseKilogramsForWeight
        let weight = shouldUseKilogramsForWeight ? currentForm.weightInKilograms : currentForm.weightInKilograms.kilogram.to(.pound).value
        let isIndeterminateWeight = weight < 0
        let weightUnit = shouldUseKilogramsForWeight ? MassFormatter.Unit.kilogram : .pound
        let weightString: String
        if isIndeterminateWeight {
            // Display "???" when weight == -1
            weightString = "???"
        } else {
            weightString = MassFormatter.weight.string(fromValue: weight, unit: weightUnit)
        }
        return weightString
    }
    private var baseExperienceYieldString: String { "\(currentForm.baseExperienceYield)" }

    private let verticalPadding: CGFloat = 4.0

    var body: some View {
        List {
            header()
            sections()
        }
        .listStyle(GroupedListStyle())
        .navigationTitle(pokemon.name)
    }

    init(
        pokemon: Pokemon,
        game: Game,
        numberKeyPath: String = #keyPath(Pokemon.z_index)) {
        self.game = game
        self.numberKeyPath = numberKeyPath
        self._pokemonFetchRequest = FetchRequest(fetchRequest: Pokemon.fetchRequest(for: pokemon, game: game))
    }

    init(
        pokemon: Pokemon,
        game: Game,
        formIndex: Int,
        numberKeyPath: String = #keyPath(Pokemon.z_index)) {
        self.game = game
        self.numberKeyPath = numberKeyPath
        self._pokemonFetchRequest = FetchRequest(fetchRequest: Pokemon.fetchRequest(for: pokemon, game: game))
        self._currentFormIndex = State(initialValue: formIndex)
    }

    @ViewBuilder
    private func header() -> some View {
        let image = PokemonImage(form: currentForm)

        let metadata = VStack(alignment: .leading, spacing: 16.0) {
            VStack(alignment: .leading) {
                Text("#\(pokemon.pokedexNumberString(forKeyPath: numberKeyPath)) \(pokemon.name)")
                    .monospacedLargeTitle()

                Text("\(currentForm.species) Pokémon")
                    .monospacedBody()
            }

            PokemonTypes(
                primaryType: currentForm.primaryType,
                secondaryType: currentForm.secondaryType)
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
                image
                    .frame(idealWidth: 300, idealHeight: 300, alignment: .center)
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
                Section(header: SectionHeader("Forms")) {
                    VStack(alignment: .leading) {
                        PokemonForms(
                            forms: pokemon.forms,
                            backgroundColor: Color(self.currentForm.color.uiColor),
                            currentIndex: $currentFormIndex)
                        Text(currentForm.name)
                            .monospacedCaption()
                            .animation(.none)
                    }
                }
                .padding(.vertical, verticalPadding)
            }
        case .pokedexEntry:
            Section(header: SectionHeader("Pokédex Entry")) {
                DescriptionCell(text: currentForm.pokedexEntry)
            }
            .padding(.vertical, verticalPadding)
        case .abilities:
            if game.hasAbilities {
                PokemonAbilitiesSection(form: currentForm, game: game)
                    .padding(.vertical, verticalPadding)
            }
        case .typeEffectiveness:
            Section(header: SectionHeader("Type Effectiveness")) {
                PokemonTypeEffectiveness(primaryType: currentForm.primaryType, secondaryType: currentForm.secondaryType, kind: .defense, game: game)
                    .centered()
            }
            .padding(.vertical, verticalPadding)
        case .moves:
            Section(header: SectionHeader("Moves")) {
                NavigationLink(destination: PokemonLearnset(form: currentForm, game: game, initialLearnsetType: .level)) {
                    Value1Cell(text: "By Level")
                }
                NavigationLink(destination: PokemonLearnset(form: currentForm, game: game, initialLearnsetType: .machine)) {
                    Value1Cell(text: "By Machine")
                }
                if game.hasBreeding {
                    NavigationLink(destination: PokemonLearnset(form: currentForm, game: game, initialLearnsetType: .breed)) {
                        Value1Cell(text: "By Breeding")
                    }
                }
                if game.hasTutoring {
                    NavigationLink(destination: PokemonLearnset(form: currentForm, game: game, initialLearnsetType: .tutor)) {
                        Value1Cell(text: "By Tutoring")
                    }
                }
            }
            .padding(.vertical, verticalPadding)
        case .evolutions:
            if let evolutions = currentForm.evolutions,
               !evolutions.isEmpty {
                Section(header: SectionHeader("Evolutions")) {
                    PokemonEvolutions(evolutions: evolutions)
                }
                .padding(.vertical, verticalPadding)
            }
        case .locations:
            Section(header: SectionHeader("Locations")) {
                NavigationLink(destination: PokemonLocations(pokemon: pokemon, game: game)) {
                    Text("View Locations")
                        .monospacedBody()
                }
            }
        case .baseStats:
            Section(header: SectionHeader("Base Stats")) {
                PokemonBaseStats(baseStats: currentForm.baseStats)
            }
            .padding(.vertical, verticalPadding)
        case .evYield:
            Section(header: SectionHeader("EV Yield")) {
                PokemonEVYield(
                    hp: currentForm.evYield.hp,
                    attack: currentForm.evYield.attack,
                    defense: currentForm.evYield.defense,
                    specialAttack: currentForm.evYield.specialAttack,
                    specialDefense: currentForm.evYield.specialDefense,
                    speed: currentForm.evYield.speed)
            }
            .padding(.vertical, verticalPadding)
        case .pokedexNumbers:
            Section(header: SectionHeader("Pokédex Numbers")) {
                PokemonPokedexNumbers(pokedexNumbers: pokemon.pokedexNumbers)
            }
            .padding(.vertical, verticalPadding)
        case .basicInfo:
            Section(header: SectionHeader("Basic Info")) {
                Value1Cell(text: "Introduced", detailText: generationIntroducedString)
                Value1Cell(text: "Height", detailText: heightString)
                Value1Cell(text: "Weight", detailText: weightString)
                GenderRatioCell(maleRatio: pokemon.maleRatio)
                EggGroupsCell(eggGroups: pokemon.eggGroups)
                Value1Cell(text: "Catch Rate", detailText: catchRateString)
                Value1Cell(text: "Leveling Rate", detailText: levelingRateString)
                Value1Cell(text: "Base Friendship", detailText: baseFriendshipString)
                Value1Cell(text: "Base XP Yield", detailText: baseExperienceYieldString)
            }
            .padding(.vertical, verticalPadding)
        }
    }

}

struct PokemonDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PokemonDetail(pokemon: Pokemon.generateCharizard(game: .sword), game: .sword)
                .injectDependencies()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
