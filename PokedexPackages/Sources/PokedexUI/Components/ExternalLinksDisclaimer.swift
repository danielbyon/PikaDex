//
//  ExternalLinksDisclaimer.swift
//  
//
//  Created by Daniel Byon on 11/6/22.
//

import DesignSystem
import SwiftUI

public struct ExternalLinksDisclaimer: View {

    public var body: some View {
        Text("PikaDex is not affiliated with the content of these external websites, which may have different terms and conditions and/or privacy policies.")
            .monospacedFootnote()
    }

    public init() { }

}

struct ExternalLinksDisclaimer_Previews: PreviewProvider {
    static var previews: some View {
        ExternalLinksDisclaimer()
    }
}
