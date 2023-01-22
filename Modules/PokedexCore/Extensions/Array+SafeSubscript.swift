//
//  Array+SafeSubscript.swift
//  
//
//  Created by Daniel Byon on 10/29/22.
//

import Foundation

extension Array {

    public subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }

}
