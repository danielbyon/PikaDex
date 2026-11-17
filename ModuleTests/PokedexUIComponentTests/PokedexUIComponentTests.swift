import PokedexCore
import SwiftUI
import UIKit
import XCTest
@testable import PokedexUI

final class PokedexUIComponentTests: XCTestCase {

    @MainActor
    func testNavigationEnvironmentDefaultInjectionAndClear() {
        var environment = EnvironmentValues()
        let store = environment.navigationStore

        XCTAssertEqual(store.path.count, 0)

        environment.navigationStore = store
        XCTAssertTrue(environment.navigationStore === store)

        store.path.append("pokemon-detail")
        XCTAssertEqual(store.path.count, 1)

        store.clear()
        XCTAssertEqual(store.path.count, 0)
    }

    @MainActor
    func testSelectPokemonFormActionForwardsSelectedForm() {
        var selectedForm: PokemonDetailForm?
        let action = SelectPokemonFormAction { selectedForm = $0 }

        action(.charizard)

        XCTAssertEqual(selectedForm, .charizard)
    }

    @MainActor
    func testSearchQueryStringBindingPreservesContainsAndExactModes() {
        var query: SearchQuery = .contains("Pika")
        let binding = Binding<SearchQuery>(get: { query }, set: { query = $0 }).toString()

        XCTAssertEqual(binding.wrappedValue, "Pika")
        binding.wrappedValue = "Eevee"
        XCTAssertEqual(query, .contains("Eevee"))

        query = .exact("Mr. Mime")
        XCTAssertEqual(binding.wrappedValue, "Mr. Mime")
        binding.wrappedValue = "Mime Jr."
        XCTAssertEqual(query, .exact("Mime Jr."))
    }

    @MainActor
    func testOnFirstAppearRunsOnlyOnceAcrossRepeatedAppearances() async {
        let firstAppearance = expectation(description: "The hosted view appears")
        let disappearance = expectation(description: "The hosted view disappears")
        let repeatedAppearance = expectation(description: "The hosted view appears again")
        let firstAction = expectation(description: "The first-appearance action runs")
        var appearanceStateIdentities: [UUID] = []
        var actionCount = 0
        var observedDisappearance = false
        let tabs = UITabBarController()
        let host = UIHostingController(
            rootView: AppearanceLifecycleProbe(
                onAppear: { identity in
                    appearanceStateIdentities.append(identity)
                    if appearanceStateIdentities.count == 1 {
                        firstAppearance.fulfill()
                    } else if appearanceStateIdentities.count == 2 {
                        repeatedAppearance.fulfill()
                    }
                },
                onDisappear: {
                    guard tabs.selectedIndex == 1, !observedDisappearance else { return }
                    observedDisappearance = true
                    disappearance.fulfill()
                },
                onFirstAppear: {
                    actionCount += 1
                    if actionCount == 1 {
                        firstAction.fulfill()
                    }
                }
            )
        )
        let otherController = UIViewController()
        host.tabBarItem = UITabBarItem(title: "Observed", image: nil, tag: 0)
        otherController.tabBarItem = UITabBarItem(title: "Other", image: nil, tag: 1)
        tabs.viewControllers = [host, otherController]
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
        window.rootViewController = tabs
        window.makeKeyAndVisible()
        defer {
            window.isHidden = true
            window.rootViewController = nil
        }

        await fulfillment(of: [firstAppearance, firstAction], timeout: 10)
        XCTAssertEqual(appearanceStateIdentities.count, 1)

        tabs.selectedIndex = 1
        await fulfillment(of: [disappearance], timeout: 10)

        tabs.selectedIndex = 0

        await fulfillment(of: [repeatedAppearance], timeout: 10)
        XCTAssertGreaterThanOrEqual(appearanceStateIdentities.count, 2)
        XCTAssertEqual(Set(appearanceStateIdentities).count, 1)
        XCTAssertEqual(actionCount, 1)
    }

}

private struct AppearanceLifecycleProbe: View {

    @State private var stateIdentity = UUID()

    let onAppear: (UUID) -> Void
    let onDisappear: () -> Void
    let onFirstAppear: () -> Void

    var body: some View {
        Text("PokedexUI test")
            .onAppear {
                onAppear(stateIdentity)
            }
            .onDisappear(perform: onDisappear)
            .onFirstAppear(perform: onFirstAppear)
    }

}
