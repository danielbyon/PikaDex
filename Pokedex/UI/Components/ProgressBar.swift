//
//  ProgressBar.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/22/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct ProgressBar: View {

    var progress: Double
    var color: Color
    var backgroundColor = Color.gray.opacity(0.5)
    var useGradient: Bool = true
    var useRoundedProgress: Bool = false

    var body: some View {
        ZStack {
            if (0.0...1.0).contains(progress) {
                Rectangle()
                    .fill(backgroundColor)
                GeometryReader { geo in
                    HStack {
                        Rectangle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [
                                    self.useGradient ? self.color.opacity(0.6) : self.color,
                                    self.color
                                ]),
                                startPoint: UnitPoint(x: 0, y: 0),
                                endPoint: UnitPoint(x: 1, y: 0)))
                            .frame(width: self.progressWidth(for: geo))
                            .clippedToCapsule(self.useRoundedProgress)
                        if self.progress != 1.0 {
                            Spacer()
                        }
                    }
                }
                .animation(.spring())
            } else {
                Spacer()
            }
        }
        .clipShape(Capsule(style: .circular))
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

    func clippedToCapsule(_ isClipped: Bool) -> some View {
        isClipped ? AnyView(self.clipShape(Capsule(style: .circular))) : AnyView(self)
    }

}
