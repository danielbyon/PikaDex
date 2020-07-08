//
//  StoreHeader.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/28/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct StoreHeader: View {

    var body: some View {
        VStack(spacing: 24.0) {
            Text("Premium Access")
                .font(.largeTitle)
                .bold()
                .centered()
            Text("Get premium by game family or per console!")
                .bold()
            Text("Premium gives the following benefits")
                .multilineTextAlignment(.center)
                .font(.callout)
            VStack(alignment: .leading) {
                StoreHeaderCell(imageSystemName: "gamecontroller", text: "Game data for each game purchased")
                StoreHeaderCell(imageSystemName: "checkmark.seal", text: "Unlocks advanced features such as Battle Assistant, Teams, Dual Type Checker, and location maps", detailText: "(Maps are fully supported for Generation 5 and earlier games)")
                StoreHeaderCell(imageSystemName: "nosign", text: "Never see advertisements")
                StoreHeaderCell(imageSystemName: "heart", text: "Supports the project and future updates")
            }
            .padding(.horizontal, 8.0)
        }
    }

}

struct StoreHeader_Previews: PreviewProvider {
    static var previews: some View {
        StoreHeader()
    }
}

private struct StoreHeaderCell: View {

    let imageSystemName: String
    let text: String
    var detailText: String?

    var body: some View {
        HStack(alignment: .top, spacing: 24.0) {
            Image(systemName: imageSystemName)
                .iconized()
            VStack(alignment: .leading, spacing: 4.0) {
                Text(text)
                    .multilineTextAlignment(.leading)
                if detailText != nil {
                    Text(detailText!)
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                }
            }
            Spacer(minLength: 0)
        }
    }

}

private extension Image {

    func iconized() -> some View {
        resizable()
            .scaledToFit()
            .frame(width: 24.0, height: 24.0)
    }

}
