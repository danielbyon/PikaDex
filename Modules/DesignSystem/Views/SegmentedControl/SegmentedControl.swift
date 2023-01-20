//
//  SegmentedControl.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/4/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI
import UIKit

public struct SegmentedControl<Segment>: View
where Segment: CaseIterable & Hashable & RawRepresentable,
      Segment.AllCases: RandomAccessCollection,
      Segment.RawValue == String {

    @Binding var selectedSegment: Segment
    var segments: [Segment]

    public var body: some View {
        Picker("", selection: $selectedSegment) {
            ForEach(segments, id: \.self) { segment in
                Text(segment.rawValue)
                    .tag(segment)
            }
        }
        .pickerStyle(.segmented)
    }

    public init(
        selectedSegment: Binding<Segment>,
        segments: [Segment] = Array(Segment.allCases)
    ) {
        self._selectedSegment = selectedSegment
        self.segments = segments
    }

}
