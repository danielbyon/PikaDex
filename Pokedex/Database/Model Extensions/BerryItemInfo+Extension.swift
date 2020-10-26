//
//  BerryItemInfo+Extension.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/28/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Fetch Requests
public extension BerryItemInfo {

}

//// MARK: - Identifiable
//extension BerryItemInfo: Identifiable {
//
//    public var id: String { item.name }
//
//}

// MARK: - Values
public extension BerryItemInfo {

    var firmness: BerryFirmness? {
        get { z_firmness != nil ? BerryFirmness(rawValue: z_firmness!) : nil }
        set { z_firmness = newValue?.rawValue }
    }

    var itemDescription: String {
        get { z_itemDescription! }
        set { z_itemDescription = newValue }
    }

    var item: Item {
        get { z_item! }
        set { z_item = newValue }
    }

}
