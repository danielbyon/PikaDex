//
//  SegmentedControl.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/4/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI
import UIKit

struct SegmentedControl<Segment>: View where
    Segment: CaseIterable & Hashable & Identifiable & RawRepresentable,
    Segment.AllCases: RandomAccessCollection,
    Segment.RawValue == String {

    @Binding var selectedSegment: Segment
    var segments: [Segment] = Array(Segment.allCases)

    var body: some View {
        Picker("", selection: $selectedSegment) {
            ForEach(segments) { segment in
                Text(segment.rawValue)
                    .tag(segment)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }

}
