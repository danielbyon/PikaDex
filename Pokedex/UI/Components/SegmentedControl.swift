//
//  SegmentedControl.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/4/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI
import UIKit

struct SegmentedControl<Content>: UIViewRepresentable where Content: Equatable {

    let titles: [String]
    let values: [Content]
    @Binding var selectedSegmentIndex: Content

    class Coordinator: NSObject {

        let values: [Content]
        var value: Binding<Content>

        init(values: [Content], value: Binding<Content>) {
            self.values = values
            self.value = value
        }

        @objc func valueChanged(_ sender: UISegmentedControl) {
            self.value.wrappedValue = values[sender.selectedSegmentIndex]
        }

    }

    init?(titles: [String], values: [Content], selectedSegmentIndex: Binding<Content>) {
        guard titles.count == values.count && values.contains(selectedSegmentIndex.wrappedValue) else { return nil }
        self.titles = titles
        self.values = values
        self._selectedSegmentIndex = selectedSegmentIndex
    }

    func makeUIView(context: UIViewRepresentableContext<SegmentedControl>) -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: titles)
        segmentedControl.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        return segmentedControl
    }

    func updateUIView(_ uiView: UISegmentedControl, context: UIViewRepresentableContext<SegmentedControl>) {
        uiView.selectedSegmentIndex = values.firstIndex(of: selectedSegmentIndex) ?? 0
    }

    func makeCoordinator() -> SegmentedControl.Coordinator {
        Coordinator(values: values, value: $selectedSegmentIndex)
    }

}
