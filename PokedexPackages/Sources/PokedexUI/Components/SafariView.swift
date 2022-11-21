//
//  SafariView.swift
//  
//
//  Created by Daniel Byon on 11/5/22.
//

import SafariServices
import SwiftUI

public struct SafariView: UIViewControllerRepresentable {

    public let url: URL
    public let configuration: SFSafariViewController.Configuration?

    public init(
        url: URL,
        configuration: SFSafariViewController.Configuration? = nil
    ) {
        self.url = url
        self.configuration = configuration
    }

    public func makeUIViewController(context: Context) -> SFSafariViewController {
        if let configuration {
            return SFSafariViewController(url: url, configuration: configuration)
        } else {
            return SFSafariViewController(url: url)
        }
    }

    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
    }

}
