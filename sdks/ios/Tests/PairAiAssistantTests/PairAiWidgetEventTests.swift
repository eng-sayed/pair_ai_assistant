import Foundation
import XCTest
@testable import PairAiAssistant

final class PairAiWidgetEventTests: XCTestCase {
    func testParsesWidgetReady() {
        let event = PairAiWidgetEvent.tryParse(
            #"{"type":"widget:ready","data":{"type":"widget:ready"},"origin":"http://localhost:3000","ts":"2026-08-12T21:00:00Z"}"#
        )
        XCTAssertNotNil(event)
        XCTAssertEqual(event?.type, "widget:ready")
        XCTAssertEqual(event?.origin, "http://localhost:3000")
    }

    func testParsesUnreadCount() {
        let event = PairAiWidgetEvent.tryParse(
            #"{"type":"widget:unreadCount","data":{"type":"widget:unreadCount","count":3},"origin":"https://widgets-test.trypair.ai","ts":"2026-08-12T21:00:00Z"}"#
        )
        XCTAssertEqual(event?.type, "widget:unreadCount")
        XCTAssertEqual((event?.data["count"] as? NSNumber)?.intValue, 3)
    }

    func testInvalidJsonReturnsNil() {
        XCTAssertNil(PairAiWidgetEvent.tryParse("not-json"))
    }

    func testMissingTypeReturnsNil() {
        XCTAssertNil(PairAiWidgetEvent.tryParse(#"{"data":{}}"#))
    }
}
