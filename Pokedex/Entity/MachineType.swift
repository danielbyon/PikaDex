//
//  MachineType.swift
//  
//
//  Created by Daniel Byon on 2/17/20.
//

import Foundation

public enum MachineType: String, CaseIterable, Identifiable {

    case tm = "TM"
    case hm = "HM"
    case tr = "TR"

    public var id: String { rawValue }

    public var intValue: Int {
        switch self {
        case .tm:
            return 0
        case .hm:
            return 1
        case .tr:
            return 2
        }
    }

    public init?(intValue: Int) {
        switch intValue {
        case 0:
            self = .tm
        case 1:
            self = .hm
        case 2:
            self = .tr
        default:
            return nil
        }
    }

}
