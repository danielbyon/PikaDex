import SwiftUI
import UIKit
import XCTest
@testable import DesignSystem

final class DesignSystemComponentTests: XCTestCase {
    @MainActor func testEqualBadgesHaveConsistentSetMembership() async {
        let first = Badge(title: "Fire", fillColor: .red)
        let second = Badge(title: "Fire", fillColor: .red, equalWidths: false, isSmall: false)
        let result = await Task.detached {
            (first == second, Set([first, second]).count)
        }.value
        XCTAssertTrue(result.0)
        XCTAssertEqual(result.1, 1)
    }

    @MainActor func testEveryBadgeValueParticipatesInEquality() {
        let original = Badge(title: "Fire", fillColor: .red)
        for changed in [Badge(title: "Water", fillColor: .red), Badge(title: "Fire", fillColor: .blue), Badge(title: "Fire", fillColor: .red, equalWidths: true), Badge(title: "Fire", fillColor: .red, isSmall: true)] {
            XCTAssertNotEqual(original, changed)
        }
    }

    @MainActor func testDoneActionIsDeferredAndDeliveredSynchronously() {
        let calls = NSMutableArray()
        let button = DoneButton { calls.add(Thread.isMainThread) }
        _ = button.body
        XCTAssertEqual(calls.count, 0)
        button.action()
        XCTAssertEqual(calls.count, 1)
        button.action()
        XCTAssertEqual(calls.count, 2)
        XCTAssertTrue((0..<calls.count).allSatisfy { (calls[$0] as? Bool) == true })
    }

    @MainActor func testDefaultSegmentsAndBindingRoundTrip() {
        var selection = Segment.first
        let control = SegmentedControl(selectedSegment: Binding(get: { selection }, set: { selection = $0 }))
        XCTAssertEqual(control.segments, Segment.allCases)
        control.selectedSegment = .second
        XCTAssertEqual(selection, .second)
        selection = .third
        XCTAssertEqual(control.selectedSegment, .third)
    }

    @MainActor func testCustomSegmentOrderAndExternalSelection() {
        var selection = Segment.second
        let control = SegmentedControl(selectedSegment: Binding(get: { selection }, set: { selection = $0 }), segments: [.third, .first])
        XCTAssertEqual(control.segments, [.third, .first])
        XCTAssertEqual(control.selectedSegment, .second)
        control.selectedSegment = .first
        XCTAssertEqual(selection, .first)
    }

    @MainActor func testSpriteBundleSelectionAndResourceRendering() throws {
        XCTAssertNil(Sprite("rare-candy").bundle)
        let sprite = Sprite("rare-candy", bundle: .resources, width: 48)
        XCTAssertTrue(sprite.bundle === Bundle.resources)
        XCTAssertNotNil(UIImage(named: "rare-candy", in: .resources, compatibleWith: nil))
        let image = try XCTUnwrap(ImageRenderer(content: sprite).uiImage)
        XCTAssertEqual(image.size, CGSize(width: 48, height: 48))
        XCTAssertEqual(exportedDomainValues().1, .national)
    }

    @MainActor func testComponentsRenderAtNormalDynamicType() throws {
        try renderFixture(dynamicType: .large, width: 430)
    }

    @MainActor func testComponentsRenderAtAccessibilityDynamicType() throws {
        try renderFixture(dynamicType: .accessibility3, width: 320)
    }

    // Attach images to the result bundle for comparison on the same runtime.
    @MainActor private func renderFixture(dynamicType: DynamicTypeSize, width: CGFloat) throws {
        let content = VStack(alignment: .leading) {
            Badge(title: "Fire", fillColor: .red)
            Badge(title: "Water", fillColor: .blue, equalWidths: true, isSmall: true)
            DescriptionCell(text: "A multiline description of a Pokémon and its habitat.")
            Value1Cell(text: "Name", detailText: "Detail", image: Image(systemName: "star"))
            Value1Cell(text: "Name")
            Value3Cell(title: "Charizard", subtitle: "Mega Charizard X", detail: "Level 01", image: UIImage(systemName: "star"))
            Value3Cell(title: "Charizard")
            Sprite("rare-candy", bundle: .resources)
            Text("Body").monospacedBody()
            Text("Bold body").monospacedBoldBody()
            Text("Callout").monospacedCallout()
            Text("Caption").monospacedCaption()
            Text("Caption 2").monospacedCaption2()
            Text("Footnote").monospacedFootnote()
            Text("Headline").monospacedHeadline()
            Text("Large title").monospacedLargeTitle()
            Text("Subheadline").monospacedSubheadline()
            Text("Title").monospacedTitle()
            Text("Title 2").monospacedTitle2()
            Text("Title 3").monospacedTitle3()
        }.frame(width: width).environment(\.dynamicTypeSize, dynamicType)
        let image = try XCTUnwrap(ImageRenderer(content: content).uiImage)
        XCTAssertEqual(image.size.width, width)
        XCTAssertGreaterThan(image.size.height, 0)
        let attachment = XCTAttachment(image: image)
        attachment.name = "components-\(dynamicType)-\(Int(width))"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

private enum Segment: String, CaseIterable {
    case first = "First", second = "Second", third = "Third"
}
