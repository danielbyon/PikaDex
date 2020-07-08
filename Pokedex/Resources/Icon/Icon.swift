//
//  Icon.swift
//
//  Created by Zac White.
//  Copyright © 2020 Velos Mobile LLC / https://velosmobile.com / All rights reserved.
//

import SwiftUI

struct Icon : View {

    var canvas: CanvasProxy

    var body: some View {
        let ballRedColor = Color(red: 1.0, green: 0.212, blue: 0.373)//Color(red: 1.0, green: 0.143, blue: 0.15)
        let ballWhiteColor = Color(red: 0.932, green: 0.932, blue: 0.932)//Color.white
        let ballBlackColor = Color(red: 0.0, green: 0.029, blue: 0.032)
        let ballDiameter: CGFloat = 400

//        let earColor = Color(red: 0.976, green: 0.867, blue: 0.514)
//        let earTipColor = Color.black

        let boltColor = Color(red: 1.0, green: 0.791, blue: 0.0)

        let bookArcRadius: CGFloat = 50
        let bookWidth: CGFloat = 500
        let bookHeight: CGFloat = 700
        let bookPagesHeight: CGFloat = 100
        let bookPagesColor = Color.gray//Color(red: 1.0, green: 0.791, blue: 0.0)
        let bookBindingColor = Color(red: 0.211, green: 0.44, blue: 1.0)

        let bookTopLeftX: CGFloat = (1024 - bookWidth) / 2 + 50
        let bookTopLeftY: CGFloat = (1024 - bookHeight) / 2 - 50

        let bookTopRightX: CGFloat = bookTopLeftX + bookWidth
        let bookTopRightY: CGFloat = bookTopLeftY

        let bookBottomLeftX: CGFloat = bookTopLeftX
        let bookBottomLeftY: CGFloat = bookTopLeftY + bookHeight

        let bookBottomRightX: CGFloat = bookTopRightX
        let bookBottomRightY: CGFloat = bookTopRightY + bookHeight

        func bookBinding(_ canvas: CanvasProxy) -> Path {
            Path { path in
                path.move(to: .init(x: canvas[bookTopLeftX], y: canvas[bookTopLeftY]))
                path.addLine(to: .init(x: canvas[bookTopLeftX - bookArcRadius], y: canvas[bookTopLeftY]))
                path.addArc(
                    center: .init(x: canvas[bookTopLeftX - bookArcRadius], y: canvas[bookTopLeftY + bookArcRadius]),
                    radius: canvas[bookArcRadius],
                    startAngle: .degrees(-90),
                    endAngle: .degrees(-180),
                    clockwise: true)

                path.addLine(to: .init(x: canvas[bookTopLeftX - 2 * bookArcRadius], y: canvas[bookBottomLeftY + bookArcRadius]))
                path.addArc(
                    center: .init(x: canvas[bookTopLeftX - bookArcRadius], y: canvas[bookBottomLeftY + bookArcRadius]),
                    radius: canvas[bookArcRadius],
                    startAngle: .degrees(180),
                    endAngle: .degrees(90),
                    clockwise: true)
                path.addLine(to: .init(x: canvas[bookBottomRightX], y: canvas[bookBottomRightY + bookPagesHeight]))
                path.addLine(to: .init(x: canvas[bookBottomRightX], y: canvas[bookBottomRightY]))
                path.move(to: .init(x: canvas[bookBottomLeftX], y: canvas[bookBottomLeftY]))
                path.addLine(to: .init(x: canvas[bookBottomLeftX - bookArcRadius], y: canvas[bookBottomLeftY]))
                path.addArc(
                    center: .init(x: canvas[bookBottomLeftX - bookArcRadius], y: canvas[bookBottomLeftY + bookArcRadius]),
                    radius: canvas[bookArcRadius],
                    startAngle: .degrees(-90),
                    endAngle: .degrees(-180),
                    clockwise: true)
            }
        }

        func book(_ canvas: CanvasProxy) -> Path {
            Path { path in
                path.addLines([
                    .init(x: canvas[bookTopLeftX], y: canvas[bookTopLeftY]),
                    .init(x: canvas[bookTopRightX], y: canvas[bookTopRightY]),
                    .init(x: canvas[bookBottomRightX], y: canvas[bookBottomRightY]),
                    .init(x: canvas[bookBottomLeftX], y: canvas[bookBottomLeftY])
                ])
                path.closeSubpath()
            }
        }

        func pages(_ canvas: CanvasProxy) -> Path {
            Path { path in
                path.addLine(to: .init(x: canvas[bookBottomLeftX - bookArcRadius], y: canvas[bookBottomLeftY]))
                path.addArc(
                    center: .init(x: canvas[bookBottomLeftX - bookArcRadius], y: canvas[bookBottomLeftY + bookArcRadius]),
                    radius: canvas[bookArcRadius],
                    startAngle: .degrees(-90),
                    endAngle: .degrees(-270),
                    clockwise: true)
                path.addLine(to: .init(x: canvas[bookBottomRightX], y: canvas[bookBottomRightY + bookPagesHeight]))
                path.addLine(to: .init(x: canvas[bookBottomRightX], y: canvas[bookBottomRightY]))
            }
        }

        func ball() -> some View {
            ZStack {
                // Ball outline
                CircleArc(startAngle: .zero, endAngle: .init(degrees: 180), fill: ballRedColor)
                    .frame(width: canvas[ballDiameter - 40])
                CircleArc(startAngle: .init(degrees: 180), endAngle: .zero, fill: ballWhiteColor)
                    .frame(width: canvas[ballDiameter - 40])

                // Bar
                Rectangle()
                    .fill(ballBlackColor)
                    .frame(height: canvas[30])

                // Button
                Circle()
                    .fill(ballBlackColor)
                    .frame(width: canvas[120])
                Circle()
                    .fill(ballWhiteColor)
                    .frame(width: canvas[80])
                Circle()
                    .fill(ballBlackColor)
                    .frame(width: canvas[40])
            }
            .frame(width: canvas[bookWidth])
            .clipShape(Circle())
        }

        func topHalfPage() -> Path {
            Path { path in
                path.addLines([
                    .init(x: canvas[bookTopLeftX], y: canvas[bookTopLeftY]),
                    .init(x: canvas[bookTopRightX], y: canvas[bookTopRightY]),
                    .init(x: canvas[bookBottomRightX], y: canvas[bookTopRightY + bookHeight / 2.0]),
                    .init(x: canvas[bookBottomLeftX], y: canvas[bookTopLeftY + bookHeight / 2.0])
                ])
                path.closeSubpath()
            }
        }

        func bottomHalfPage() -> Path {
            Path { path in
                path.addLines([
                    .init(x: canvas[bookBottomRightX], y: canvas[bookTopRightY + bookHeight / 2.0]),
                    .init(x: canvas[bookBottomLeftX], y: canvas[bookTopLeftY + bookHeight / 2.0]),
                    .init(x: canvas[bookTopLeftX], y: canvas[bookBottomLeftY]),
                    .init(x: canvas[bookTopRightX], y: canvas[bookBottomRightY])
                ])
                path.closeSubpath()
            }
        }

        func tail() -> Path {
            Path { path in
                path.move(to: .init(x: canvas[600], y: canvas[200]))
                path.addLines([
                    .init(x: canvas[600], y: canvas[200]), // 1
                    .init(x: canvas[300], y: canvas[350]), // 2
                    .init(x: canvas[500], y: canvas[500]), // 3
                    .init(x: canvas[425], y: canvas[550]), // 4
                    .init(x: canvas[500], y: canvas[650]), // 5
                    .init(x: canvas[450], y: canvas[700]), // 6
                    .init(x: canvas[550], y: canvas[850]), // 7
                    .init(x: canvas[600], y: canvas[800]), // 8
                    .init(x: canvas[525], y: canvas[725]), // 9
                    .init(x: canvas[650], y: canvas[625]), // 10
                    .init(x: canvas[525], y: canvas[550]), // 11
                    .init(x: canvas[650], y: canvas[450]), // 12
                    .init(x: canvas[550], y: canvas[375]), // 13
                    .init(x: canvas[700], y: canvas[275]) // 14
                ])
                path.closeSubpath()
            }
        }

        func boltImage() -> some View {
            Image("bolt.fill")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(boltColor)
                .frame(width: canvas[400], height: canvas[400])
        }

        func bolt() -> Path {
            Path { path in
                path.move(to: .init(x: canvas[700], y: canvas[200]))
                path.addLines([
                    .init(x: canvas[550], y: canvas[200]),
                    .init(x: canvas[400], y: canvas[425]),
                    .init(x: canvas[475], y: canvas[425]),
                    .init(x: canvas[450], y: canvas[600]),
                    .init(x: canvas[600], y: canvas[375]),
                    .init(x: canvas[525], y: canvas[375])
                ])
                path.closeSubpath()
            }
        }

        return ZStack {
            bookBinding(canvas)
                .fill(bookBindingColor)

            pages(canvas)
                .fill(bookPagesColor)

            bookBinding(canvas)
                .strokedPath(StrokeStyle(lineWidth: canvas[25]))
                .foregroundColor(Color.black)

            book(canvas)
                .fill(ballRedColor)

//            topHalfPage()
//                .fill(ballRedColor)
//
//            bottomHalfPage()
//                .fill(ballWhiteColor)

            book(canvas)
                .strokedPath(StrokeStyle(lineWidth: canvas[25]))
                .foregroundColor(Color.black)

            // Try for 1.1
//            tail()
//                .strokedPath(StrokeStyle(lineWidth: canvas[25]))

//            Text("P")
//                .foregroundColor(.white)
//                .font(Font.system(size: canvas[400], design: .monospaced))
//                .offset(x: canvas[50], y: canvas[-50])

            // Bar
//            Rectangle()
//                .fill(ballBlackColor)
//                .frame(width: canvas[bookWidth], height: canvas[30])
//                .offset(x: canvas[50], y: canvas[-50])
//            ball()
//                .offset(x: canvas[50], y: canvas[-50])

//            boltImage()
//                .offset(x: canvas[50], y: canvas[-50])

            bolt()
                .fill(boltColor)
                .foregroundColor(Color.black)
                .offset(x: canvas[50], y: canvas[50])
            bolt()
                .strokedPath(StrokeStyle(lineWidth: canvas[25]))
                .foregroundColor(Color.black)
                .offset(x: canvas[50], y: canvas[50])
        }
    }

}

#if DEBUG
struct Icon_Previews : PreviewProvider {
    static var previews: some View {
        IconStack { canvas in
            Icon(canvas: canvas)
        }
    }
}
#endif
