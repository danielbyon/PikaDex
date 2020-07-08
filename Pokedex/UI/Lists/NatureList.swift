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
        List {
            AlternatingBackgroundForEach(natures) { nature in
                NatureCell(viewModel: nature)
            }
        }
        .navigationBarTitle("Natures")
        .navigationBarItems(trailing: DoneButton(action: dismiss))
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
        VStack(alignment: .leading, spacing: 8.0) {
            Text(viewModel.title)
                .monospacedBody()
            if viewModel.isNeutral {
                Text("Neutral")
                    .foregroundColor(Color(AppColor.red.uiColor))
                    .monospacedCaption()
                    .centered()
            } else {
                HStack {
                    HStack(spacing: 0.0) {
                        Spacer(minLength: 0.0)
                        Text(viewModel.increasedStatTitle)
                            .foregroundColor(Color(AppColor.green.uiColor))
                        Spacer(minLength: 0.0)
                    }
                    HStack(spacing: 0.0) {
                        Spacer(minLength: 0.0)
                        Text(viewModel.decreasedStatTitle)
                            .foregroundColor(Color(AppColor.red.uiColor))
                        Spacer(minLength: 0.0)
                    }
                    HStack(spacing: 0.0) {
                        Spacer(minLength: 0.0)
                        Text(viewModel.likedFlavorTitle)
                            .foregroundColor(Color(AppColor.green.uiColor))
                        Spacer(minLength: 0.0)
                    }
                    HStack(spacing: 0.0) {
                        Spacer(minLength: 0.0)
                        Text(viewModel.dislikedFlavorTitle)
                            .foregroundColor(Color(AppColor.red.uiColor))
                        Spacer(minLength: 0.0)
                    }
                }
                .monospacedCaption()
                .centered()
            }
        }
        .contentShape(Rectangle())
    }

}
