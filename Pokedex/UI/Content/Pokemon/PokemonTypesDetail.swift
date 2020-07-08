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
    @State private var currentSegment = 0

    var body: some View {
        Group {
            if secondaryType == nil {
                primaryTypeView
            } else {
                VStack {
                    SegmentedControl(titles: [primaryType.rawValue, secondaryType!.rawValue], values: [0, 1], selectedSegmentIndex: $currentSegment)
                        .padding(.horizontal)
                        .padding(.top)
                    if currentSegment == 0 {
                        primaryTypeView
                    } else {
                        secondaryTypeView
                    }
                }
            }
        }
    }

    private var primaryTypeView: some View {
        TypeDetail(type: primaryType, game: appContext.currentGame)
    }

    private var secondaryTypeView: some View {
        TypeDetail(type: secondaryType!, game: appContext.currentGame)
    }

}

struct PokemonTypesDetail_Previews: PreviewProvider {
    static var previews: some View {
        PokemonTypesDetail(primaryType: .fire, secondaryType: .flying)
            .modifier(Dependencies())
    }
}
