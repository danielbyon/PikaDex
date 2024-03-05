//
//  PokedexResources.swift
//  PokedexResources
//
//  Created by Daniel Byon on 3/19/23.
//  Copyright © 2023 Daniel Byon. All rights reserved.
//

import Foundation

extension Bundle {

    public static var resources: Bundle { Bundle(for: BundleMarker.self) }

}

private final class BundleMarker { }
