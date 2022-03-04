//
//  BagItemInfo+Extension.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Fetch Requests
public extension BagItemInfo {

}

//// MARK: - Identifiable
//extension BagItemInfo: Identifiable {
//
//    public var id: String { item.name }
//
//}

// MARK: - Values
public extension BagItemInfo {

    var itemDescription: String {
        get { z_itemDescription! }
        set { z_itemDescription = newValue }
    }

    var pocket: Pocket? {
        get { Pocket(rawValue: z_pocket ?? "") }
        set { z_pocket = newValue?.rawValue }
    }

    var item: Item {
        get { z_item! }
        set { z_item = newValue }
    }

}
