//
//  HomeButton.swift
//  
//
//  Created by Daniel Byon on 11/6/22.
//

import SwiftUI

public struct HomeButton: View {

    @Environment(\.navigationStore) private var navigationStore

    public var body: some View {
        Button {
            withAnimation {
                navigationStore.clear()
            }
        } label: {
            Image(systemName: "house")
        }
    }

    public init() { }

}

struct HomeButton_Previews: PreviewProvider {
    static var previews: some View {
        HomeButton()
    }
}
