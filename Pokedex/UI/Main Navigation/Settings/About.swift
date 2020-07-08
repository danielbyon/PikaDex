//
//  About.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/25/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import AppSupport

struct About: View {

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
        VStack(alignment: .leading, spacing: spacing) {
            Card {
                Text(aboutText)
                    .monospacedBody()
            }

            MailComposeButton(emailAddress: contactEmail, subject: contactSubject) {
                BigColoredButton(icon: Image(systemName: "envelope"), title: "Contact", textColor: .white, fillColor: AppColor.red.uiColor)
                    .fixedSize(horizontal: false, vertical: true)
            }

            OpenURLButton(url: reviewURL) {
                BigColoredButton(icon: Image(systemName: "square.and.pencil"), title: "Write a review", textColor: .white, fillColor: AppColor.red.uiColor)
                    .fixedSize(horizontal: false, vertical: true)
            }

            OpenURLButton(url: seeMoreAppsURL) {
                BigColoredButton(icon: Image(systemName: "app.badge"), title: "See my other apps", textColor: .white, fillColor: AppColor.red.uiColor)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Card {
                Text(copyrightText)
                    .monospacedCaption()
            }

            AppInfo()
        }
    }
}

struct AboutContent_Previews: PreviewProvider {
    static var previews: some View {
        About()
    }
}
