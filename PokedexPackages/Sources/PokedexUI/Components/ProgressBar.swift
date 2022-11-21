//
//  ProgressBar.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/22/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

public struct ProgressBar: View {

    let progress: Double
    let color: Color
    let backgroundColor: Color
    let useGradient: Bool
    let useRoundedProgress: Bool

    public var body: some View {
        ZStack {
            if (0.0...1.0).contains(progress) {
                Rectangle()
                    .fill(backgroundColor)
                GeometryReader { geo in
                    HStack {
                        Rectangle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [
                                    useGradient ? color.opacity(0.6) : color,
                                    color
                                ]),
                                startPoint: UnitPoint(x: 0, y: 0),
                                endPoint: UnitPoint(x: 1, y: 0)))
                            .frame(width: progressWidth(for: geo))
                            .clippedToCapsule(useRoundedProgress)
                        if progress != 1.0 {
                            Spacer()
                        }
                    }
                }
                .animation(.spring(), value: progress)
            } else {
                Spacer()
            }
        }
        .clipShape(Capsule(style: .circular))
    }

    public init(
        progress: Double,
        color: Color,
        backgroundColor: Color = .gray.opacity(0.5),
        useGradient: Bool = true,
        useRoundedProgress: Bool = false
    ) {
        self.progress = progress
        self.color = color
        self.backgroundColor = backgroundColor
        self.useGradient = useGradient
        self.useRoundedProgress = useRoundedProgress
    }

    private func progressWidth(for proxy: GeometryProxy) -> CGFloat {
        if progress == 0.0 {
            return 0.0
        } else if useRoundedProgress {
            let minFactor: CGFloat = 0.15
            let minWidth = proxy.size.width * minFactor
            return minWidth + ((proxy.size.width * (1.0 - minFactor)) * CGFloat(min(progress, 1.0)))
        } else {
            return CGFloat(progress) * proxy.size.width
        }
    }

}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProgressBar(progress: 0.5, color: .green)
                .frame(height: 44)
            ProgressBar(progress: 0.5, color: .green, useRoundedProgress: true)
                .frame(height: 44)
        }
    }
}

private extension View {

    @ViewBuilder
    func clippedToCapsule(_ isClipped: Bool) -> some View {
        if isClipped {
            self.clipShape(Capsule(style: .circular))
        } else {
            self
        }
    }

}
