//
//  UIKitStepper.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/12/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct UIKitStepper: UIViewRepresentable {

    @Binding var value: Double
    var step = 1.0
    var minimumValue = 0.0
    var maximumValue = 100.0

    class Coordinator: NSObject {

        @Binding var value: Double

        init(value: Binding<Double>) {
            self._value = value
        }

        @objc func valueChanged(_ sender: UIStepper) {
            value = sender.value
        }

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(value: $value)
    }

    func makeUIView(context: Context) -> UIStepper {
        if value < minimumValue {
            value = minimumValue
        } else if value > maximumValue {
            value = maximumValue
        }

        let stepper = UIStepper()
        stepper.value = value
        stepper.stepValue = step
        stepper.minimumValue = minimumValue
        stepper.maximumValue = maximumValue
        stepper.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        return stepper
    }

    func updateUIView(_ uiView: UIStepper, context: Context) {
        uiView.value = value
    }

}

private struct StepperTest: View {

    @State var value = 0.0

    var body: some View {
        HStack {
            UIKitStepper(value: $value, step: 1.0, minimumValue: 1.0, maximumValue: 100.0)
            Text("\(value)")
        }
    }

}

struct BridgedStepper_Previews: PreviewProvider {

    static var previews: some View {
        StepperTest()
    }
}
