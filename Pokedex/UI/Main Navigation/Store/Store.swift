//
//  Store.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import StoreKit

struct Store: View {

    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var storeViewModel: StoreViewModel
    @State private var thanksMessage: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 44.0) {
                    if storeViewModel.hasProducts {
                        StoreSections(
                            consoleProducts: storeViewModel.allConsoleProducts,
                            gameProducts: storeViewModel.allGameProducts,
                            tipProducts: storeViewModel.allTipProducts,
                            isPurchasing: storeViewModel.isPurchasing) { product in
                                self.storeViewModel.purchaseProduct(product)
                        }
                        RestorePurchases(onRestoreTriggered: self.storeViewModel.restorePurchases)
                    } else if storeViewModel.error != nil {
                        VStack {
                            Text("Unable to load store")
                            Button(action: self.refreshProducts) {
                                Text("Refresh")
                                    .padding()
                            }
                            .buttonStyle(DefaultButtonStyle())
                        }
                        .centered()
                    } else {
                        Text("Loading store...")
                            .centered()
                    }
                }
                .padding()
            }
            .navigationBarTitle("Store", displayMode: .inline)
            .navigationBarItems(trailing: DoneButton(action: dismiss))
            .onAppear {
                self.refreshProducts()
            }
            .alert(item: $storeViewModel.alertInfo) { alertInfo in
                Alert(
                    title: Text(alertInfo.title),
                    message: alertInfo.message != nil ? Text(alertInfo.message!) : nil,
                    dismissButton: .default(Text(alertInfo.dismissTitle)))
            }
            .onReceive(NotificationCenter.default.publisher(for: StoreClient.purchasedNotification).receive(on: DispatchQueue.main)) { notification in
                self.handlePurchasedNotification(notification)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func refreshProducts() {
        storeViewModel.requestProducts()
    }

    private func dismiss() {
        presentation.wrappedValue.dismiss()
    }

    private func handlePurchasedNotification(_ notification: Notification) {
        debugPrint("Purchase notification received")
        if StoreClient.isTipPurchaseNotification(notification) {
            thanksMessage = "Thanks for the tip! ♥️"
        } else {
            thanksMessage = "Use \"Choose Game\" on the main screen to select the purchased game(s)."
        }
    }

}

struct Store_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = StoreViewModel()
        viewModel.hasLoadedProducts = true
        viewModel.allConsoleProducts = [
            ProductViewModel(description: "Test product Test product Test product Test product Test product Test product Test product Test product ", pokepediaProduct: .allGames, price: "$4.99", product: SKProduct(), title: "All Games"),
            ProductViewModel(description: "Test product", pokepediaProduct: .all3DSGames, price: "$1.99", product: SKProduct(), title: "All 3DS Games")
        ]
        viewModel.allGameProducts = [
            ProductViewModel(description: nil, pokepediaProduct: .rubySapphireEmerald, price: "$0.99", product: SKProduct(), title: "Ruby/Sapphire/Emerald")
        ]
        viewModel.allTipProducts = [
            ProductViewModel(description: nil, pokepediaProduct: .smallTip, price: "$0.99", product: SKProduct(), title: "Small Tip")
        ]
        return Group {
            Store()
                .environmentObject(viewModel)
            Store()
                .environmentObject(viewModel)
                .colorScheme(.dark)
        }
//            .environment(\.sizeCategory, .extraExtraExtraLarge)
    }
}
