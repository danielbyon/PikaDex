//
//  PreviewContainer.swift
//  
//
//  Created by Daniel Byon on 9/20/22.
//

import SwiftUI

public struct PreviewContainer<Content: View>: View {

    private let content: Content

    public var body: some View {
        content
            .injectPersistentContainer()
    }

    public init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

}
