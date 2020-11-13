//
//  AlertController.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct AlertController: UIViewControllerRepresentable {

    let title: String?
    let message: String?
    let placeholder: String?
    @Binding var value: String?
    @Binding var isPresented: Bool

    class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var value: String?

        init(value: Binding<String?>) {
            self._value = value
            super.init()
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            value = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
            return true
        }

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(value: $value)
    }

    func makeUIViewController(context: Context) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.font = UIFont.preferredFont(forTextStyle: .body)
            textField.placeholder = self.placeholder
            textField.delegate = context.coordinator
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.value = nil
            self.isPresented = false
        })
        alert.addAction(UIAlertAction(title: "Submit", style: .default) { _ in
            self.isPresented = false
        })
        return alert
    }

    func updateUIViewController(_ uiViewController: UIAlertController, context: Context) {

    }

}
