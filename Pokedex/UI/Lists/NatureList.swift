//
//  NatureList.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/23/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct NatureList: View {

    @Environment(\.presentationMode) var presentationMode

    var natures: [NatureCellViewModel] { Nature.all.map { .init(nature: $0) } }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(spacing: 16.0), count: 2), spacing: 16.0) {
                ForEach(natures) { nature in
                    NatureCell(viewModel: nature)
                }
            }
            .padding()
        }
        .navigationTitle("Natures")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                DoneButton(action: dismiss)
            }
        }
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

}

struct NatureList_Previews: PreviewProvider {
    static var previews: some View {
        NatureList()
    }
}

struct NatureCellViewModel {

    let title: String
    let isNeutral: Bool
    let increasedStatTitle: String
    let increasedStatColor: UIColor
    let decreasedStatTitle: String
    let decreasedStatColor: UIColor
    let likedFlavorTitle: String
    let likedFlavorColor: UIColor
    let dislikedFlavorTitle: String
    let dislikedFlavorColor: UIColor

    init(nature: Nature) {
        assert((nature.increasedStat != nil
            && nature.decreasedStat != nil
            && nature.likedFlavor != nil
            && nature.dislikedFlavor != nil)
            || (nature.increasedStat == nil
                && nature.decreasedStat == nil
                && nature.likedFlavor == nil
                && nature.dislikedFlavor == nil))
        title = nature.name
        isNeutral = nature.increasedStat == nil
        increasedStatTitle = "↑ " + (nature.increasedStat?.title ?? "")
        increasedStatColor = nature.increasedStat?.uiColor ?? .clear
        decreasedStatTitle = "↓ " + (nature.decreasedStat?.title ?? "")
        decreasedStatColor = nature.decreasedStat?.uiColor ?? .clear
        likedFlavorTitle = "👍 " + (nature.likedFlavor?.title ?? "")
        likedFlavorColor = nature.likedFlavor?.uiColor ?? .clear
        dislikedFlavorTitle = "👎 " + (nature.dislikedFlavor?.title ?? "")
        dislikedFlavorColor = nature.dislikedFlavor?.uiColor ?? .clear
    }

}

extension NatureCellViewModel: Identifiable {

    var id: String { title }

}

struct NatureCell: View {

    let viewModel: NatureCellViewModel

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 8.0) {
                Text(viewModel.title)
                    .monospacedBody()
                if viewModel.isNeutral {
                    HStack {
                        Text("Neutral")
                            .foregroundColor(Color(AppColor.red.uiColor))
                            .monospacedCaption()
                        Spacer()
                    }
                    Spacer()
                } else {
                    VStack(alignment: .leading, spacing: 4.0) {
                        HStack {
                            Text(viewModel.increasedStatTitle)
                                .foregroundColor(Color(AppColor.green.uiColor))
                            Spacer()
                        }
                        HStack {
                            Text(viewModel.decreasedStatTitle)
                                .foregroundColor(Color(AppColor.red.uiColor))
                            Spacer()
                        }
                        HStack {
                            Text(viewModel.likedFlavorTitle)
                                .foregroundColor(Color(AppColor.green.uiColor))
                            Spacer()
                        }
                        HStack {
                            Text(viewModel.dislikedFlavorTitle)
                                .foregroundColor(Color(AppColor.red.uiColor))
                            Spacer()
                        }
                    }
                    .monospacedCaption()
                    .centered()
                }
            }
            .contentShape(Rectangle())
        }
    }

}
