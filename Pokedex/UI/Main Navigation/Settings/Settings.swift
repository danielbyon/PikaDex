//
//  Settings.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/22/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct Settings: View {

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        NavigationView {
            List {
                Section(footer: About().padding(.top, 10.0)) {
                    Toggle(isOn: $appSettings.shouldUseKilogramsForWeight) {
                        Text("Show weight in kilograms")
                    }
                    Toggle(isOn: $appSettings.shouldUseMetersForHeight) {
                        Text("Show height in meters")
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Settings")
            .navigationBarItems(trailing: DoneButton(action: dismiss))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
            .injectDependencies()
    }
}
