//
//  LearnsetType.swift
//  
//
//  Created by Daniel Byon on 2/17/20.
//

import Foundation

public enum LearnsetType: String, CaseIterable, Identifiable {

    case level = "Level"
    case machine = "Machine"
    case breed = "Breeding"
    case tutor = "Tutoring"

    public var id: String { rawValue }

}
