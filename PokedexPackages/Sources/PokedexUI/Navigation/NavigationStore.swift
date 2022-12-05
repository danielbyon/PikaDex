//
//  NavigationStore.swift
//  Pokedex
//
//  Created by Daniel Byon on 9/9/22.
//  Copyright © 2022 Daniel Byon. All rights reserved.
//

import SwiftUI

public class NavigationStore: ObservableObject {

    @Published public var path = NavigationPath()

    public init() { }

    public func restore(from data: Data) {
        do {
            let representation = try JSONDecoder().decode(
                NavigationPath.CodableRepresentation.self,
                from: data)
            path = NavigationPath(representation)
        } catch {
            path = NavigationPath()
        }
    }

    public func encoded() -> Data? {
        guard let representation = path.codable else {
            return nil
        }
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(representation)
            return data
        } catch {
            // Handle error.
            debugPrint(error)
            return nil
        }
    }

    public func clear() {
        path = .init()
    }

}
