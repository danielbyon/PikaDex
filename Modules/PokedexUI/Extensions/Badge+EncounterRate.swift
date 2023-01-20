//
//  Badge+EncounterRate.swift
//  
//
//  Created by Daniel Byon on 9/28/22.
//

import DesignSystem
import SwiftUI

extension Badge {

    public init(encounterRate: EncounterRate) {
        let title: String
        let fillColor: UIColor
        switch encounterRate {
        case .percent(let percent):
            title = "\(percent)%"
            if percent < 10 {
                fillColor = #colorLiteral(red: 1.0, green: 0.165, blue: 0.225, alpha: 1.0)
            } else if percent == 10 {
                fillColor = #colorLiteral(red: 1.0, green: 0.464, blue: 0.0, alpha: 1.0)
            } else if percent < 20 {
                fillColor = #colorLiteral(red: 1.0, green: 0.865, blue: 0.181, alpha: 1.0)
            } else if percent < 30 {
                fillColor = #colorLiteral(red: 0.537, green: 0.912, blue: 0.0, alpha: 1.0)
            } else {
                fillColor = #colorLiteral(red: 0.0, green: 0.822, blue: 0.302, alpha: 1.0)
            }
        case .rarity(let rarity):
            title = rarity.rawValue
            switch rarity {
            case .common:
                fillColor = #colorLiteral(red: 0.0, green: 0.822, blue: 0.302, alpha: 1.0)
            case .uncommon:
                fillColor = #colorLiteral(red: 1.0, green: 0.865, blue: 0.181, alpha: 1.0)
            case .rare:
                fillColor = #colorLiteral(red: 1.0, green: 0.165, blue: 0.225, alpha: 1.0)
            case .limited:
                fillColor = #colorLiteral(red: 0.451, green: 0.451, blue: 0.451, alpha: 1.0)
            }
        case .unknown:
            title = "Unknown"
            fillColor = #colorLiteral(red: 0.451, green: 0.451, blue: 0.451, alpha: 1)
        }
        self.init(title: title, fillColor: fillColor)
    }

}
