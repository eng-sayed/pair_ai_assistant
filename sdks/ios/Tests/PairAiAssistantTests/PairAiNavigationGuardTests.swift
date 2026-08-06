import XCTest
@testable import PairAiAssistant

final class PairAiNavigationGuardTests: XCTestCase {
    private var guardInstance: PairAiNavigationGuard!

    override func setUp() {
        super.setUp()
        guardInstance = PairAiNavigationGuard([
            "https://widgets-test.trypair.ai",
        ])
    }

    func testAllowsSameOriginHttpsNavigation() {
        XCTAssertTrue(guardInstance.isAllowed("https://widgets-test.trypair.ai/sdk.js"))
    }

    func testAllowsAboutBlank() {
        XCTAssertTrue(guardInstance.isAllowed("about:blank"))
    }

    func testBlocksJavascriptScheme() {
        XCTAssertFalse(guardInstance.isAllowed("javascript:alert(1)"))
    }

    func testBlocksForeignOrigins() {
        XCTAssertFalse(guardInstance.isAllowed("https://evil.example/phish"))
    }

    func testBlocksInvalidUrls() {
        XCTAssertFalse(guardInstance.isAllowed("not a url"))
    }

    func testOriginForDefaultHttpsPort() {
        let uri = URL(string: "https://widgets-test.trypair.ai/path")!
        XCTAssertEqual(PairAiNavigationGuard.origin(for: uri), "https://widgets-test.trypair.ai")
    }

    func testOriginForCustomPort() {
        let uri = URL(string: "https://widgets-test.trypair.ai:8443/path")!
        XCTAssertEqual(PairAiNavigationGuard.origin(for: uri), "https://widgets-test.trypair.ai:8443")
    }
}
