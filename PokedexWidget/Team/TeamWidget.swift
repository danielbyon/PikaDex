//
//  TeamWidget.swift
//  PokedexWidgetExtension
//
//  Created by Daniel Byon on 12/8/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import WidgetKit
import SwiftUI

struct TeamWidget: Widget {
    let kind: String = "TeamWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: TeamConfigurationIntent.self, provider: TeamProvider()) { entry in
            TeamWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Teams")
        .description("Shows one of your teams.")
        .supportedFamilies([.systemMedium])
    }
}
