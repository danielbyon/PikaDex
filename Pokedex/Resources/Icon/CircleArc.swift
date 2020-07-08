//
//  CircleArc.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/9/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct CircleArc<S>: View where S: ShapeStyle {

    let startAngle: Angle
    let endAngle: Angle
    let fill: S

    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: self.center(for: geo))
                path.addArc(center: self.center(for: geo), radius: self.radius(for: geo), startAngle: self.startAngle, endAngle: -self.endAngle, clockwise: true)
            }
            .fill(self.fill)
        }
    }

    private func center(for proxy: GeometryProxy) -> CGPoint {
        .init(x: proxy.size.width / 2, y: proxy.size.height / 2)
    }

    private func radius(for proxy: GeometryProxy) -> CGFloat {
        if proxy.size.width > proxy.size.height {
            return proxy.size.height / 2
        } else {
            return proxy.size.width / 2
        }
    }

}

struct CircleArc_Previews: PreviewProvider {
    static var previews: some View {
        CircleArc(startAngle: .zero, endAngle: .init(degrees: 135), fill: Color.red)
    }
}
