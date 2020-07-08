//
//  View+Fonts.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/27/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

extension View {

    func monospacedLargeTitle() -> some View {
        font(.system(.largeTitle, design: .monospaced))
    }

    func monospacedTitle() -> some View {
        font(.system(.title, design: .monospaced))
    }

    func monospacedHeadline() -> some View {
        font(.system(.headline, design: .monospaced))
    }

    func monospacedSubheadline() -> some View {
        font(.system(.subheadline, design: .monospaced))
    }

    func monospacedBody() -> some View {
        font(.system(.body, design: .monospaced))
    }

    func monospacedCaption() -> some View {
        font(.system(.caption, design: .monospaced))
    }

    func monospacedCallout() -> some View {
        font(.system(.callout, design: .monospaced))
    }

    func monospacedBoldBody() -> some View {
        font(Font.system(.body, design: .monospaced).bold())
    }

}

extension Text {

    func monospacedLargeTitle() -> Text {
        font(.system(.largeTitle, design: .monospaced))
    }

    func monospacedTitle() -> Text {
        font(.system(.title, design: .monospaced))
    }

    func monospacedHeadline() -> Text {
        font(.system(.headline, design: .monospaced))
    }

    func monospacedSubheadline() -> Text {
        font(.system(.subheadline, design: .monospaced))
    }

    func monospacedBody() -> Text {
        font(.system(.body, design: .monospaced))
    }

    func monospacedCaption() -> Text {
        font(.system(.caption, design: .monospaced))
    }

    func monospacedCallout() -> Text {
        font(.system(.callout, design: .monospaced))
    }

    func monospacedBoldBody() -> Text {
        font(Font.system(.body, design: .monospaced).bold())
    }

}
