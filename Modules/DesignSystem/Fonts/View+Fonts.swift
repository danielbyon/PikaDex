//
//  View+Fonts.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/27/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

extension View {

    public func monospacedBody() -> some View {
        font(.system(.body, design: .monospaced))
            .minimumScaleFactor(0.8)
    }

    public func monospacedBoldBody() -> some View {
        font(Font.system(.body, design: .monospaced))
            .minimumScaleFactor(0.8)
            .bold()
    }

    public func monospacedCallout() -> some View {
        font(.system(.callout, design: .monospaced))
            .minimumScaleFactor(0.8)
    }

    public func monospacedCaption() -> some View {
        font(.system(.caption, design: .monospaced))
            .minimumScaleFactor(0.8)
    }

    public func monospacedCaption2() -> some View {
        font(.system(.caption2, design: .monospaced))
            .minimumScaleFactor(0.8)
    }

    public func monospacedFootnote() -> some View {
        font(.system(.footnote, design: .monospaced))
            .minimumScaleFactor(0.8)
    }

    public func monospacedHeadline() -> some View {
        font(.system(.headline, design: .monospaced))
            .minimumScaleFactor(0.8)
    }

    public func monospacedLargeTitle() -> some View {
        font(.system(.largeTitle, design: .monospaced))
            .minimumScaleFactor(0.8)
    }

    public func monospacedSubheadline() -> some View {
        font(.system(.subheadline, design: .monospaced))
            .minimumScaleFactor(0.8)
    }

    public func monospacedTitle() -> some View {
        font(.system(.title, design: .monospaced))
            .minimumScaleFactor(0.8)
    }

    public func monospacedTitle2() -> some View {
        font(.system(.title2, design: .monospaced))
            .minimumScaleFactor(0.8)
    }

    public func monospacedTitle3() -> some View {
        font(.system(.title3, design: .monospaced))
            .minimumScaleFactor(0.8)
    }

}
