//
//  PannableZoomableImageView.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/1/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import WebKit

public struct PannableZoomableImageView: UIViewRepresentable {

    let image: UIImage?

    public init(image: UIImage?) {
        self.image = image
    }

    public func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        if let data = image?.pngData() {
            view.load(data, mimeType: "image/png", characterEncodingName: "utf8", baseURL: URL(fileURLWithPath: ""))
        }
        return view
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {

    }

}
