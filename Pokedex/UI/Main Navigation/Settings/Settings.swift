//
//  Settings.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/22/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import AppSupport

struct Settings: View {

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appSettings: AppSettings

    private var spacing: CGFloat { 16.0 }
    private var aboutText: String {
        """
        \(AppConstants.appName) is an unofficial app for fans, made by a fan. Thousands of hours by a sole developer have gone into making this the best Pokémon app to help you while playing the games!

        If you have any questions, suggestions or corrections, please reach out to me!
        """
    }
    private var copyrightText: String {
        """
        This app is not affiliated with Nintendo, GAME FREAK, or The Pokémon Company. Pokémon and Pokémon characters are trademarks of Nintendo. Use of Pokémon characters, images, and information is supported under fair use, no copyright infringement is intended.
        """
    }
    private var contactEmail: String { "pikadex@danielbyon.com" }
    private var contactSubject: String {
        var subject = "\(AppConstants.appName) Feedback"
        if let version = AppConstants.appVersion {
            subject += ": v\(version)"
        }
        return subject
    }
    private var reviewURL: URL { URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1509561856&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&action=write-review")! }
    private var seeMoreAppsURL: URL { URL(string: "itms-apps://itunes.apple.com/us/artist/daniel-byon/id309681721")! }

    var body: some View {
        List {
            Toggle("Show weight in kilograms", isOn: $appSettings.shouldUseKilogramsForWeight)

            Toggle("Show height in meters", isOn: $appSettings.shouldUseMetersForHeight)

            NavigationLink("Pokémon detail ordering", destination: PokemonDetailOrderSettings())

            Card {
                Text(aboutText)
                    .monospacedBody()
            }

            MailComposeButton(emailAddress: contactEmail, subject: contactSubject) {
                BigColoredButton(icon: Image(systemName: "envelope"), title: "Contact", textColor: .white, fillColor: AppColor.red.color)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Link(destination: reviewURL) {
                BigColoredButton(icon: Image(systemName: "square.and.pencil"), title: "Write a review", textColor: .white, fillColor: AppColor.red.color)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Link(destination: seeMoreAppsURL) {
                BigColoredButton(icon: Image(systemName: "app.badge"), title: "See my other apps", textColor: .white, fillColor: AppColor.red.color)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Card {
                Text(copyrightText)
                    .monospacedCaption()
            }

            AppInfo()
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                DoneButton(action: dismiss)
            }
        }
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
