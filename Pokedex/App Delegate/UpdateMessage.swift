//
//  UpdateMessage.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/25/21.
//  Copyright © 2021 Daniel Byon. All rights reserved.
//

import SwiftUI

struct UpdateMessage: View {

    @Environment(\.dismiss) var dismiss

    private var title: String {
        if let appVersion = AppConstants.appVersion {
            return "Pikadex v\(appVersion)"
        } else {
            assertionFailure()
            return "Pikadex"
        }
    }
    
    private let newFeatures: [String] = [
        "National Pokédex",
        "Added search to abilities, items, locations, machines, and moves"
    ]

    private let bugFixes: [String] = [
        "Fixed Team Builder bug, where making any edit would kick the user back to the team list screen",
        "Fixed Team Builder member editor bug, where selecting a move, item, ability, etc. would not pop the user back to the member editor screen",
        "Fixed Lilligant's evolution info showing up on Basculin's detail page",
        "Fixed Scraggy's evolution level",
        "Fixed psychic/ghost type effectiveness (was 0x, fixed to 2x)"
    ]

    var body: some View {
        NavigationView {
            List {
                if !newFeatures.isEmpty {
                    Section("New Features") {
                        ForEach(newFeatures, id: \.self) { message in
                            Text(message)
                                .lineLimit(nil)
                        }
                    }
                }

                if !bugFixes.isEmpty {
                    Section("Bug Fixes") {
                        ForEach(bugFixes, id: \.self) { message in
                            Text(message)
                                .lineLimit(nil)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    DoneButton {
                        dismiss()
                    }
                }
            }
            .navigationTitle(title)
        }
        .navigationViewStyle(.stack)
    }
}

struct UpdateMessage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UpdateMessage()
        }
    }
}
