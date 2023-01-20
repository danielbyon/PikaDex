//
//  NatureCell.swift
//  
//
//  Created by Daniel Byon on 10/21/22.
//

import PokedexUI
import SwiftUI

public struct NatureCell: View {

    let viewModel: NatureCellViewModel

    public var body: some View {
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

    public init(viewModel: NatureCellViewModel) {
        self.viewModel = viewModel
    }

}

struct NatureCell_Previews: PreviewProvider {
    static var previews: some View {
        NatureCell(viewModel: .init(nature: .adamant))
    }
}
