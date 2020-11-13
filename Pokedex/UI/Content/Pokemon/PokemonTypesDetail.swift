//
//  PokemonTypesDetail.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/16/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokemonTypesDetail: View {

    let primaryType: PokemonType
    let secondaryType: PokemonType?

    @EnvironmentObject var appContext: AppContext
    @State private var selectedSegment: String

    var body: some View {
        Group {
            if let secondaryType = secondaryType {
                VStack {
                    Picker("", selection: $selectedSegment) {
                        Text(primaryType.rawValue)
                            .tag(primaryType.rawValue)
                        Text(secondaryType.rawValue)
                            .tag(secondaryType.rawValue)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    if selectedSegment == primaryType.rawValue {
                        primaryTypeView
                    } else {
                        TypeDetail(type: secondaryType, game: appContext.currentGame)
                    }
                }
            } else {
                primaryTypeView
            }
        }
    }

    private var primaryTypeView: some View {
        TypeDetail(type: primaryType, game: appContext.currentGame)
    }

    init(primaryType: PokemonType, secondaryType: PokemonType?) {
        self.primaryType = primaryType
        self.secondaryType = secondaryType
        self._selectedSegment = .init(initialValue: primaryType.rawValue)
    }

}

struct PokemonTypesDetail_Previews: PreviewProvider {
    static var previews: some View {
        PokemonTypesDetail(primaryType: .fire, secondaryType: .flying)
            .modifier(Dependencies())
    }
}
