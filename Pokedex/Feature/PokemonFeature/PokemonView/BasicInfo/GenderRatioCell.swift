//
//  GenderRatioCell.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import PokedexUI
import SwiftUI

struct GenderRatioCell: View {

    let maleRatio: Double?

    var femaleRatio: Double? { maleRatio != nil ? 100.0 - maleRatio! : nil }

    private var genderRatioString: String? {
        guard let maleRatio = maleRatio,
            let femaleRatio = femaleRatio,
            let maleString = NumberFormatter.percent.string(from: NSNumber(value: maleRatio)),
            let femaleString = NumberFormatter.percent.string(from: NSNumber(value: femaleRatio)) else {
                return nil
        }
        return "\(maleString) M, \(femaleString) F"
    }

    var body: some View {
        HStack(spacing: 0) {
            Text("Gender Ratio")
                .monospacedBody()
                .multilineTextAlignment(.leading)
            Spacer(minLength: 16)
            if let maleRatio = maleRatio, maleRatio >= 0.0 {
                VStack(spacing: 4.0) {
                    ProgressBar(
                        progress: maleRatio / 100.0,
                        color: Color(#colorLiteral(red: 0.2078431373, green: 0.3294117647, blue: 1, alpha: 1)),
                        backgroundColor: Color(#colorLiteral(red: 1, green: 0.462745098, blue: 0.8784313725, alpha: 1)),
                        useGradient: false
                    )
                        .frame(height: 8.0)
                    Text(genderRatioString ?? "Genderless")
                        .monospacedCaption()
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: 300)
            } else {
                Text(genderRatioString ?? "Genderless")
                    .monospacedBody()
            }
        }
        .padding(.vertical, 4.0)
    }

}

struct GenderRatioCell_Previews: PreviewProvider {
    static var previews: some View {
        GenderRatioCell(maleRatio: 50.0)
    }
}
