//
//  EggGroup+UIColor.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import UIKit

extension EggGroup {

    var uiColor: UIColor {
        switch self {
        case .amorphous: return #colorLiteral(red: 0.5411764706, green: 0.5411764706, blue: 0.5411764706, alpha: 1)
        case .bug: return #colorLiteral(red: 0.6666666667, green: 0.7607843137, blue: 0, alpha: 1)
        case .ditto: return #colorLiteral(red: 0.6509803922, green: 0.3921568627, blue: 0.7607843137, alpha: 1)
        case .dragon: return #colorLiteral(red: 0.4784313725, green: 0.2549019608, blue: 1, alpha: 1)
        case .fairy: return #colorLiteral(red: 1, green: 0.7843137255, blue: 0.9490196078, alpha: 1)
        case .field: return #colorLiteral(red: 0.8784313725, green: 0.7529411765, blue: 0.3764705882, alpha: 1)
        case .flying: return #colorLiteral(red: 0.6980392157, green: 0.6039215686, blue: 0.9960784314, alpha: 1)
        case .grass: return #colorLiteral(red: 0.5098039216, green: 0.8235294118, blue: 0.3058823529, alpha: 1)
        case .humanLike: return #colorLiteral(red: 0.8235294118, green: 0.5882352941, blue: 0.5019607843, alpha: 1)
        case .mineral: return #colorLiteral(red: 0.4784313725, green: 0.3843137255, blue: 0.3176470588, alpha: 1)
        case .monster: return #colorLiteral(red: 0.1803921569, green: 0.6941176471, blue: 0.6117647059, alpha: 1)
        case .undiscovered: return #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        case .water1: return #colorLiteral(red: 0.5921568627, green: 0.7098039216, blue: 1, alpha: 1)
        case .water2: return #colorLiteral(red: 0.4509803922, green: 0.6039215686, blue: 0.9960784314, alpha: 1)
        case .water3: return #colorLiteral(red: 0.3490196078, green: 0.462745098, blue: 0.7568627451, alpha: 1)
        }
    }

}
