//
//  UpdateMessageView.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/25/21.
//  Copyright © 2021 Daniel Byon. All rights reserved.
//

import SwiftUI

private final class UpdateMessageViewModel: ObservableObject {

    @Published var bugFixes: [String]
    @Published var newFeatures: [String]
    @Published var upcoming: [String]

    init() {
        do {
            let fileURL = Bundle.main.url(forResource: "UpdateMessages", withExtension: "plist")!
            let data = try Data(contentsOf: fileURL)
            let updateMessages = try PropertyListDecoder().decode(UpdateMessages.self, from: data)
            bugFixes = updateMessages.bugFixes
            newFeatures = updateMessages.newFeatures
            upcoming = updateMessages.upcoming
        } catch {
            bugFixes = []
            newFeatures = []
            upcoming = []
        }
    }

}

struct UpdateMessageView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = UpdateMessageViewModel()

    private var title: String {
        if let appVersion = AppConstants.appVersion {
            return "Pikadex v\(appVersion)"
        } else {
            assertionFailure()
            return "Pikadex"
        }
    }

    var body: some View {
        NavigationStack {
            List {
                section(name: "New Features", entries: viewModel.newFeatures)
                section(name: "Bug Fixes", entries: viewModel.bugFixes)
                section(name: "Upcoming", entries: viewModel.upcoming)
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
    }

    @ViewBuilder
    private func section(name: String, entries: [String]) -> some View {
        if !entries.isEmpty {
            Section {
                ForEach(entries, id: \.self) { entry in
//                    Card {
                        Text(entry)
                            .lineLimit(nil)
//                    }
                }
            } header: {
                Text(name)
            }
        }
    }

}

struct UpdateMessage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UpdateMessageView()
        }
    }
}
