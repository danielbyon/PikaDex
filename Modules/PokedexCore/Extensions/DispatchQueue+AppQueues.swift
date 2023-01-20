//
//  DispatchQueue+App.swift
//  
//
//  Created by Daniel Byon on 10/27/22.
//

import Foundation

extension DispatchQueue {

    public static let appHighPriority = DispatchQueue(label: "com.danielbyon.pokedex.uiSupport", qos: .userInitiated)

    public static let appProcessing = DispatchQueue(label: "com.danielbyon.pokedex.processing", qos: .utility)

    public static let appMaintenance = DispatchQueue(label: "com.danielbyon.pokedex.maintenance", qos: .background)

}
