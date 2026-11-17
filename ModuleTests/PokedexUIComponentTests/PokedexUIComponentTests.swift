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
        let repeatedAppearance = expectation(description: "The action does not run a second time")
        repeatedAppearance.isInverted = true
        var invocationCount = 0
        let host = UIHostingController(
            rootView: Text("PokedexUI test")
                .onFirstAppear {
                    invocationCount += 1
                    if invocationCount == 1 {
                        firstAppearance.fulfill()
                    } else {
                        repeatedAppearance.fulfill()
                    }
                }
        )
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
        window.rootViewController = host
        window.makeKeyAndVisible()
        defer {
            window.isHidden = true
            window.rootViewController = nil
        }

        await fulfillment(of: [firstAppearance], timeout: 2)

        host.beginAppearanceTransition(false, animated: false)
        host.endAppearanceTransition()
        host.beginAppearanceTransition(true, animated: false)
        host.endAppearanceTransition()

        await fulfillment(of: [repeatedAppearance], timeout: 0.25)
        XCTAssertEqual(invocationCount, 1)
    }

}
