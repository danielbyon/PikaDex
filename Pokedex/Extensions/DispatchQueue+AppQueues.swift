//
//  DispatchQueue+AppQueues.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/19/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension DispatchQueue {

    static let appUserInitiated = DispatchQueue(label: "com.danielbyon.pikadex.userInitiated", qos: .userInitiated)

    static let appUtility = DispatchQueue(label: "com.danielbyon.pikadex.utility", qos: .utility, attributes: [.concurrent])

}
