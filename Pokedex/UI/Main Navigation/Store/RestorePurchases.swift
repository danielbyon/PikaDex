//
//  RestorePurchases.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/28/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct RestorePurchases: View {

    let onRestoreTriggered: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Restore Purchases")
                .font(.largeTitle)
                .bold()
                .centered()
            Text("Purchased Premium on another device, or reinstalled the app? Use the button below.")
                .multilineTextAlignment(.leading)
            Button(action: onRestoreTriggered) {
                Card(backgroundColor: Color(AppColor.red.uiColor)) {
                    Text("Restore Purchases")
                        .foregroundColor(.white)
                }
            }
        }
    }

}

struct RestorePurchases_Previews: PreviewProvider {
    static var previews: some View {
        RestorePurchases(onRestoreTriggered: {})
    }
}
