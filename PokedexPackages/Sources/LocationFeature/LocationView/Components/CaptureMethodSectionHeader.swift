//
//  CaptureMethodSectionHeader.swift
//  
//
//  Created by Daniel Byon on 10/19/22.
//

import SwiftUI

struct CaptureMethodSectionHeader: View {

    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .monospacedHeadline()
            Text(subtitle)
                .monospacedCaption()
        }
    }

    init(section: LocationCaptureMethodViewModel.Section) {
        self.title = section.title
        if let detail = section.detail {
            self.subtitle = "\(section.subtitle) (\(detail))"
        } else {
            self.subtitle = section.subtitle
        }
    }

}

struct CaptureMethodSectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        CaptureMethodSectionHeader(section: .init(
            title: "Main",
            subtitle: "Super Rod",
            detail: nil,
            rows: []
        ))
    }
}
