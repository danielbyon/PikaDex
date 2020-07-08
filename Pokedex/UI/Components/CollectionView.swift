//
//  CollectionView.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/10/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct FlowLayout {
    
    let containerSize: CGSize
    let spacing: UIOffset
    
    var size: CGSize { CGSize(width: containerSize.width, height: currentY + lineHeight) }
    
    private var currentX: CGFloat = 0
    private var currentY: CGFloat = 0
    private var lineHeight: CGFloat = 0
    
    init(containerSize: CGSize, spacing: UIOffset) {
        self.containerSize = containerSize
        self.spacing = spacing
    }
    
    mutating func add(element size: CGSize) -> CGRect {
        if currentX + size.width > containerSize.width {
            currentX = 0
            currentY += lineHeight + spacing.vertical
            lineHeight = 0
        }
        defer {
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing.horizontal
        }
        return CGRect(origin: CGPoint(x: currentX, y: currentY), size: size)
    }
    
}

func flowLayout<Elements>(for elements: Elements, containerSize: CGSize, spacing: UIOffset, sizes: [Elements.Element.ID: CGSize]) -> (CGSize, [Elements.Element.ID: CGSize]) where Elements: RandomAccessCollection, Elements.Element: Identifiable {
    var state = FlowLayout(containerSize: containerSize, spacing: spacing)
    var result: [Elements.Element.ID: CGSize] = [:]
    for element in elements {
        let rect = state.add(element: sizes[element.id] ?? .zero)
        result[element.id] = CGSize(width: rect.origin.x, height: rect.origin.y)
    }
    return (state.size, result)
}

struct CollectionView<Elements, Content>: View where Elements: RandomAccessCollection, Elements.Element: Identifiable, Content: View {
    
    typealias Sizes = [Elements.Element.ID: CGSize]
    
    var data: Elements
    var spacing: UIOffset = UIOffset(horizontal: 10, vertical: 10)
    var layout: (Elements, CGSize, UIOffset, Sizes) -> (CGSize, Sizes)
    var content: (Elements.Element) -> Content
    
    @State private var sizes: Sizes = [:]
    @State private var height: CGFloat = 0
    
    var body: some View {
        GeometryReader { proxy in
            self.bodyHelper(containerSize: proxy.size, offsets: self.layout(self.data, proxy.size, self.spacing, self.sizes))
        }
        .onPreferenceChange(CollectionViewSizeKey.self) {
            self.height = $0.height
        }
        .frame(height: height)
    }
    
    private func bodyHelper(containerSize: CGSize, offsets: (CGSize, Sizes)) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(data) {
                PropagateSize(content: self.content($0), id: $0.id)
                    .offset(offsets.1[$0.id] ?? .zero)
                    .animation(.default)
            }
            Color.clear
                .frame(width: offsets.0.width, height: offsets.0.height)
                .fixedSize()
        }
        .onPreferenceChange(CollectionViewItemSizeKey.self) {
            self.sizes = $0
        }
        .preference(key: CollectionViewSizeKey.self, value: offsets.0)
    }
    
}

struct PropagateSize<V: View, ID: Hashable>: View {
    
    var content: V
    var id: ID
    var body: some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: CollectionViewItemSizeKey<ID>.self, value: [self.id: proxy.size])
            })
    }
    
}

struct CollectionViewItemSizeKey<ID: Hashable>: PreferenceKey {
    
    typealias Value = [ID: CGSize]
    
    static var defaultValue: [ID: CGSize] { [:] }
    
    static func reduce(value: inout [ID: CGSize], nextValue: () -> [ID: CGSize]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }

}

struct CollectionViewSizeKey: PreferenceKey {
    
    typealias Value = CGSize
    
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
    
}

extension String: Identifiable {
    public var id: String { self }
}

struct CollectionWrapperView: View {

    let strings: [String] = (1...10).map {
        "Item \($0) " + String(repeating: "x", count: Int.random(in: 0...10))
    }

    var body: some View {
        CollectionView(data: strings, spacing: UIOffset(horizontal: 8.0, vertical: 8.0), layout: flowLayout) {
            Text($0)
                .padding(10)
                .background(Color.gray)
        }
    }
}

struct CollectionView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CollectionWrapperView()
                .border(Color.gray)
            CollectionWrapperView()
                .border(Color.gray)
            Spacer()
        }
    }
}
