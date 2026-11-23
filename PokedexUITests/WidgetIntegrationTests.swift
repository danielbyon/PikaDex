import XCTest

final class WidgetIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testWidgetRendersSelectedTeamAndOpensTeamsSection() {
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

        // Stable names let the test reuse its app-group fixtures across runs.
        let baselineTeamName = "Widget Baseline Team"
        let selectedTeamName = "Widget Selected Team"
        ensureTeam(named: baselineTeamName, containing: "Pikachu", in: app)
        ensureTeam(named: selectedTeamName, containing: "Eevee", in: app)

        let homeButton = app.buttons["Home"]
        XCTAssertTrue(homeButton.waitForExistence(timeout: 10), app.debugDescription)
        homeButton.tap()
        XCTAssertTrue(app.buttons["Pokémon"].waitForExistence(timeout: 10), app.debugDescription)
        app.terminate()

        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        XCUIDevice.shared.press(.home)
        let homeScreen = springboard.windows.firstMatch
        XCTAssertTrue(homeScreen.waitForExistence(timeout: 10), springboard.debugDescription)

        removeExistingWidgets(in: springboard)
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

    /// Removes existing PikaDex widgets so the test starts with a known Home Screen state.
    private func removeExistingWidgets(in springboard: XCUIApplication) {
        let widgets = springboard.icons.matching(
            NSPredicate(format: "identifier == %@ AND value == %@", "PikaDex", "Widget")
        )
        guard widgets.firstMatch.waitForExistence(timeout: 2) else { return }

        let existingWidgetCount = widgets.count
        for _ in 0..<existingWidgetCount {
            let widget = widgets.firstMatch
            guard widget.waitForExistence(timeout: 2) else { break }

            widget.press(forDuration: 1.5)
            let removeWidgetButton = springboard.buttons["Remove Widget"]
            XCTAssertTrue(removeWidgetButton.waitForExistence(timeout: 10), springboard.debugDescription)
            removeWidgetButton.tap()

            let confirmRemovalButton = springboard.alerts.buttons["Remove"]
            if confirmRemovalButton.waitForExistence(timeout: 3) {
                confirmRemovalButton.tap()
            }

            let doneButton = springboard.buttons["Done"]
            if doneButton.waitForExistence(timeout: 3) {
                doneButton.tap()
            }
        }

        XCTAssertFalse(widgets.firstMatch.exists, springboard.debugDescription)
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

        let doneButton = springboard.buttons["Done"].firstMatch
        if doneButton.waitForExistence(timeout: 5) {
            doneButton.tap()
        } else {
            springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.85)).tap()
            if !springboard.staticTexts[teamName].waitForExistence(timeout: 5) {
                XCUIDevice.shared.press(.home)
            }
        }

        let renderedTeam = springboard.staticTexts[teamName].firstMatch
        XCTAssertTrue(renderedTeam.waitForExistence(timeout: 15), springboard.debugDescription)
        return renderedTeam
    }

    private func ensureTeam(
        named teamName: String,
        containing memberName: String,
        in app: XCUIApplication
    ) {
        if !app.navigationBars["Teams"].exists {
            let teamsButton = app.buttons["Teams"]
            XCTAssertTrue(teamsButton.waitForExistence(timeout: 10), app.debugDescription)
            teamsButton.tap()
        }

        let team = app.staticTexts[teamName].firstMatch
        if team.waitForExistence(timeout: 2) {
            team.tap()
        } else {
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
        }

        if !app.staticTexts[memberName].firstMatch.waitForExistence(timeout: 2) {
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
        }

        let homeButton = app.buttons["Home"]
        XCTAssertTrue(homeButton.waitForExistence(timeout: 10), app.debugDescription)
        homeButton.tap()

        let teamsButton = app.buttons["Teams"]
        XCTAssertTrue(teamsButton.waitForExistence(timeout: 10), app.debugDescription)
        teamsButton.tap()
        XCTAssertTrue(app.navigationBars["Teams"].waitForExistence(timeout: 10), app.debugDescription)
    }
}
