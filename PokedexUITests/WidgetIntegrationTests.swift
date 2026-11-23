import XCTest

final class WidgetIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testWidgetRendersSelectedTeamAndOpensTeamsSection() throws {
        try requireDisposableSimulator()

        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        XCUIDevice.shared.press(.home)
        let homeScreen = springboard.windows.firstMatch
        XCTAssertTrue(homeScreen.waitForExistence(timeout: 10), springboard.debugDescription)
        assertNoExistingWidgets(in: springboard)

        let app = XCUIApplication()
        app.launch()

        let doneButton = app.buttons["Done"]
        if doneButton.waitForExistence(timeout: 3) {
            doneButton.tap()
        }

        let notNowButton = app.buttons["Not Now"]
        if notNowButton.waitForExistence(timeout: 3) {
            notNowButton.tap()
        }

        let fixtureID = String(UUID().uuidString.prefix(8))
        let baselineTeamName = "Widget Baseline \(fixtureID)"
        let selectedTeamName = "Widget Selected \(fixtureID)"
        createTeam(named: baselineTeamName, containing: "Pikachu", in: app)
        createTeam(named: selectedTeamName, containing: "Eevee", in: app)

        let homeButton = app.buttons["Home"]
        XCTAssertTrue(homeButton.waitForExistence(timeout: 10), app.debugDescription)
        homeButton.tap()
        XCTAssertTrue(app.buttons["Pokémon"].waitForExistence(timeout: 10), app.debugDescription)
        app.terminate()

        XCUIDevice.shared.press(.home)
        XCTAssertTrue(homeScreen.waitForExistence(timeout: 10), springboard.debugDescription)

        let widget = addWidget(
            baselineTeamName: baselineTeamName,
            on: homeScreen,
            springboard: springboard
        )
        let selectedTeam = configure(widget, toShow: selectedTeamName, in: springboard)
        XCTAssertTrue(
            springboard.staticTexts["Eevee"].waitForExistence(timeout: 10),
            springboard.debugDescription
        )
        selectedTeam.tap()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15), app.debugDescription)
        XCTAssertTrue(app.navigationBars["Teams"].waitForExistence(timeout: 10), app.debugDescription)
        XCTAssertTrue(app.staticTexts[selectedTeamName].exists, app.debugDescription)
    }

    private func requireDisposableSimulator() throws {
        let environment = ProcessInfo.processInfo.environment
        let simulatorName = environment["SIMULATOR_DEVICE_NAME"] ?? ""
        let expectedSimulatorName = environment["PIKADEX_WIDGET_TEST_SIMULATOR_NAME"]
        let simulatorID = environment["SIMULATOR_UDID"]
        let expectedSimulatorID = environment["PIKADEX_WIDGET_TEST_SIMULATOR_UDID"]
        guard simulatorName.hasPrefix("PikaDex Widget Integration Disposable "),
              simulatorName == expectedSimulatorName,
              let simulatorID,
              simulatorID == expectedSimulatorID,
              UUID(uuidString: simulatorID) != nil else {
            throw XCTSkip(
                "Widget integration requires the exact disposable simulator name and ID "
                    + "provided to the test launch."
            )
        }
    }

    private func assertNoExistingWidgets(in springboard: XCUIApplication) {
        let widgets = springboard.icons.matching(
            NSPredicate(format: "identifier == %@ AND value == %@", "PikaDex", "Widget")
        )
        XCTAssertFalse(
            widgets.firstMatch.exists,
            "The disposable simulator already has a PikaDex widget; create a fresh simulator.\n"
                + springboard.debugDescription
        )
    }

    private func addWidget(
        baselineTeamName: String,
        on homeScreen: XCUIElement,
        springboard: XCUIApplication
    ) -> XCUIElement {
        let existingDoneButton = springboard.buttons["Done"]
        if existingDoneButton.waitForExistence(timeout: 1) {
            existingDoneButton.tap()
        }

        homeScreen.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.35))
            .press(forDuration: 1.5)

        let editHomeScreen = springboard.buttons["Edit Home Screen"]
        if editHomeScreen.waitForExistence(timeout: 3) {
            editHomeScreen.tap()
        } else {
            let editButton = springboard.buttons["Edit"]
            if editButton.waitForExistence(timeout: 3) {
                editButton.tap()
            }
        }

        let addWidgetButton = springboard.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Add Widget'")
        ).firstMatch
        XCTAssertTrue(addWidgetButton.waitForExistence(timeout: 10), springboard.debugDescription)
        addWidgetButton.tap()

        let widgetSearchField = springboard.searchFields.firstMatch
        if widgetSearchField.waitForExistence(timeout: 5) {
            widgetSearchField.tap()
            widgetSearchField.typeText("PikaDex")
        }

        let appResult = springboard.cells.containing(.staticText, identifier: "PikaDex").firstMatch
        if appResult.waitForExistence(timeout: 10) {
            appResult.tap()
        } else {
            let appResultText = springboard.staticTexts["PikaDex"].firstMatch
            XCTAssertTrue(appResultText.waitForExistence(timeout: 10), springboard.debugDescription)
            appResultText.tap()
        }

        let widgetName = springboard.staticTexts["My Teams"].firstMatch
        XCTAssertTrue(widgetName.waitForExistence(timeout: 10), springboard.debugDescription)
        widgetName.tap()

        let addSelectedWidgetButton = springboard.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Add Widget'")
        ).firstMatch
        XCTAssertTrue(addSelectedWidgetButton.waitForExistence(timeout: 10), springboard.debugDescription)
        addSelectedWidgetButton.tap()

        let doneEditingButton = springboard.buttons["Done"].firstMatch
        if doneEditingButton.waitForExistence(timeout: 5) {
            doneEditingButton.tap()
        }

        let baselineTeam = springboard.staticTexts[baselineTeamName].firstMatch
        XCTAssertTrue(baselineTeam.waitForExistence(timeout: 15), springboard.debugDescription)
        return baselineTeam
    }

    private func configure(
        _ widget: XCUIElement,
        toShow teamName: String,
        in springboard: XCUIApplication
    ) -> XCUIElement {
        widget.press(forDuration: 1.5)
        let editWidgetButton = springboard.buttons["Edit Widget"]
        XCTAssertTrue(editWidgetButton.waitForExistence(timeout: 10), springboard.debugDescription)
        editWidgetButton.tap()

        let chooseTeamButton = springboard.buttons["Choose"]
        XCTAssertTrue(chooseTeamButton.waitForExistence(timeout: 10), springboard.debugDescription)
        chooseTeamButton.tap()

        let selectedTeamOption = springboard.staticTexts[teamName].firstMatch
        XCTAssertTrue(selectedTeamOption.waitForExistence(timeout: 10), springboard.debugDescription)
        selectedTeamOption.tap()

        let cancelTeamPicker = springboard.buttons["Cancel"].firstMatch
        if cancelTeamPicker.waitForExistence(timeout: 1) {
            cancelTeamPicker.tap()
        }

        let widgetConfigurationDescription = springboard.staticTexts[
            "Shows one of your teams."
        ].firstMatch
        XCTAssertTrue(
            widgetConfigurationDescription.waitForExistence(timeout: 10),
            springboard.debugDescription
        )
        XCTAssertTrue(springboard.buttons[teamName].exists, springboard.debugDescription)
        springboard.windows.firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.85))
            .tap()

        let renderedTeam = springboard.staticTexts[teamName].firstMatch
        XCTAssertTrue(renderedTeam.waitForExistence(timeout: 15), springboard.debugDescription)
        XCTAssertFalse(widgetConfigurationDescription.exists, springboard.debugDescription)
        return renderedTeam
    }

    private func createTeam(
        named teamName: String,
        containing memberName: String,
        in app: XCUIApplication
    ) {
        if !app.navigationBars["Teams"].exists {
            let teamsButton = app.buttons["Teams"]
            XCTAssertTrue(teamsButton.waitForExistence(timeout: 10), app.debugDescription)
            teamsButton.tap()
        }

        XCTAssertFalse(app.staticTexts[teamName].exists, app.debugDescription)
        let toolbarButtons = app.navigationBars.buttons
        XCTAssertGreaterThan(toolbarButtons.count, 0, app.debugDescription)
        toolbarButtons.element(boundBy: toolbarButtons.count - 1).tap()

        let newTeams = app.staticTexts.matching(identifier: "New Team")
        XCTAssertTrue(newTeams.firstMatch.waitForExistence(timeout: 10), app.debugDescription)
        newTeams.element(boundBy: newTeams.count - 1).tap()

        let nameField = app.textFields["Name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 10), app.debugDescription)
        let originalName = nameField.value as? String ?? ""
        nameField.tap()
        nameField.typeText(
            String(repeating: XCUIKeyboardKey.delete.rawValue, count: originalName.count)
                + teamName
        )
        let keyboardDoneButton = app.keyboards.buttons["Done"]
        if keyboardDoneButton.exists {
            keyboardDoneButton.tap()
        } else {
            nameField.typeText("\n")
        }

        let addMemberButton = app.buttons["Add Team Member"]
        XCTAssertTrue(addMemberButton.waitForExistence(timeout: 10), app.debugDescription)
        addMemberButton.tap()

        let searchField = app.searchFields["Search for a Pokémon"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10), app.debugDescription)
        searchField.tap()
        searchField.typeText(memberName)

        let member = app.staticTexts[memberName].firstMatch
        XCTAssertTrue(member.waitForExistence(timeout: 10), app.debugDescription)
        member.tap()

        let homeButton = app.buttons["Home"]
        XCTAssertTrue(homeButton.waitForExistence(timeout: 10), app.debugDescription)
        homeButton.tap()

        let teamsButton = app.buttons["Teams"]
        XCTAssertTrue(teamsButton.waitForExistence(timeout: 10), app.debugDescription)
        teamsButton.tap()
        XCTAssertTrue(app.navigationBars["Teams"].waitForExistence(timeout: 10), app.debugDescription)
    }
}
