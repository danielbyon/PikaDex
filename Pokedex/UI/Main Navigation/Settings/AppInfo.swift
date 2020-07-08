//
//  AppInfo.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct AppInfo: View {

    private var buildInfo: String {
        var string = AppConstants.appName
        if let appVersion = AppConstants.appVersion {
            string += " \(appVersion)"
        }
        if let buildVersion = AppConstants.buildVersion {
            string += " (Build \(buildVersion))"
        }
        return string
    }

    private var copyright: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return "Copyright © \(formatter.string(from: Date())) Daniel Byon"
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(buildInfo)
            Text(copyright)
        }
        .foregroundColor(.primary)
        .monospacedCaption()
    }
}

struct AppInfo_Previews: PreviewProvider {
    static var previews: some View {
        AppInfo()
    }
}
