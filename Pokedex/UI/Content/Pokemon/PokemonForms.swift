//
//  PokemonForms.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/11/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokemonForms: View {
    
    let forms: [PokemonForm]
    let backgroundColor: Color
    @Binding var currentIndex: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<forms.count, id: \.self) { i in
                    Button(action: {
                        self.currentIndex = i
                    }) {
                        Image(self.forms[i].spriteName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .padding(2)
                            .background(
                                RoundedRectangle(cornerRadius: 5.0)
                                    .stroke(lineWidth: i == self.currentIndex ? 2 : 0)
                                    .fill(self.backgroundColor)
                                    .animation(.default, value: currentIndex)
                            )
                            .padding(2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

}

struct PokemonForms_Previews: PreviewProvider {
    static var previews: some View {
        PokemonForms(forms: StoredPokemon.generateCharizard().forms, backgroundColor: Color(StoredPokemon.generateCharizard().forms[0].color.uiColor), currentIndex: .constant(0))
            .injectDependencies()
    }
}
