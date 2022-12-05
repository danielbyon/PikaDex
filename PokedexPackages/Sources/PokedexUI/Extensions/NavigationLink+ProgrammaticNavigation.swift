////
////  NavigationLink+ProgrammaticNavigation.swift
////  
////
////  Created by Daniel Byon on 10/16/22.
////
//
//import SwiftUI
//
//// https://fivestars.blog/swiftui/programmatic-navigation.html
//public extension NavigationLink where Label == EmptyView {
//
//    init?<V: Identifiable>(
//        item: Binding<V?>,
//        destination: @escaping (V) -> Destination) {
//            guard let value = item.wrappedValue else { return nil }
//
//            let isActive: Binding<Bool> = Binding(
//                get: { item.wrappedValue != nil },
//                set: { value in
//                    // There's shouldn't be a way for SwiftUI to set `true` here.
//                    if !value {
//                        item.wrappedValue = nil
//                    }
//                }
//            )
//
//            self.init(
//                destination: destination(value),
//                isActive: isActive,
//                label: { EmptyView() }
//            )
//        }
//
//}
//
//public extension View {
//
//    func navigation<V: Identifiable, Destination: View>(
//        item: Binding<V?>,
//        destination: @escaping (V) -> Destination) -> some View {
//            background(NavigationLink(item: item, destination: destination))
//        }
//
//}
//
