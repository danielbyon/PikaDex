//
//  LearnsetType.swift
//  
//
//  Created by Daniel Byon on 2/17/20.
//

import Foundation

public enum LearnsetType: String {

    case level = "Level"
    case machine = "Machine"
    case breeding = "Breeding"
    case tutoring = "Tutoring"

}

extension LearnsetType: CaseIterable { }

extension LearnsetType: Codable { }

extension LearnsetType: Hashable { }

extension LearnsetType: Identifiable {

    public var id: String { rawValue }

}
