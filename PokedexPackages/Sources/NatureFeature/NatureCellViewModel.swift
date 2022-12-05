//
//  File.swift
//  
//
//  Created by Daniel Byon on 10/21/22.
//

import PokedexUI
import SwiftUI

public struct NatureCellViewModel {

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

    public init(nature: Nature) {
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

    public var id: String { title }

}
