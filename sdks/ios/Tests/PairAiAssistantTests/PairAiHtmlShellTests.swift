import XCTest
@testable import PairAiAssistant

final class PairAiHtmlShellTests: XCTestCase {
    private let embedScript = "<script>window.PairAiWidgetSettings = {}</script>"

    func testGeneratedHtmlMatchesGoldenFixture() throws {
        let config = try PairAiEmbedConfig(
            embedScript: embedScript,
            baseUrl: "https://widgets-test.trypair.ai",
            enableArabicFontFix: true,
            enableIframeMediaPermissions: true,
            enableDebugBridge: false
        )

        let html = PairAiHtmlShell.build(config)
        let goldenURL = Bundle.module.url(
            forResource: "html_shell_golden",
            withExtension: "html",
            subdirectory: "Fixtures"
        ) ?? Bundle.module.url(forResource: "html_shell_golden", withExtension: "html")

        XCTAssertNotNil(goldenURL, "Golden fixture html_shell_golden.html must exist in test bundle")
        let golden = try String(contentsOf: XCTUnwrap(goldenURL), encoding: .utf8)
        XCTAssertEqual(html, golden)
    }

    func testGeneratedHtmlContainsExpectedMarkers() throws {
        let config = try PairAiEmbedConfig(
            embedScript: embedScript,
            baseUrl: "https://widgets-test.trypair.ai",
            enableArabicFontFix: true,
            enableIframeMediaPermissions: false,
            enableDebugBridge: false
        )

        let html = PairAiHtmlShell.build(config)

        XCTAssertTrue(html.contains("<!DOCTYPE html>"))
        XCTAssertTrue(html.contains("<html lang=\"ar\">"))
        XCTAssertTrue(html.contains(embedScript))
        XCTAssertTrue(html.contains("Noto+Sans+Arabic"))
        XCTAssertFalse(html.contains("__PAIR_AI_ASSISTANT_DEBUG__"))
        XCTAssertFalse(html.contains("__PAIR_AI_ASSISTANT_EVENTS__"))
    }

    func testEventBridgeScriptInjectedWhenEnabled() throws {
        let config = try PairAiEmbedConfig(
            embedScript: embedScript,
            baseUrl: "http://localhost:3000",
            enableArabicFontFix: false,
            enableIframeMediaPermissions: false,
            enableDebugBridge: false,
            enableEventBridge: true
        )

        let html = PairAiHtmlShell.build(config)
        XCTAssertTrue(html.contains("__PAIR_AI_ASSISTANT_EVENTS__"))
        XCTAssertTrue(html.contains("http://localhost:3000"))
    }

    func testDebugBridgeScriptInjectedWhenEnabled() throws {
        let config = try PairAiEmbedConfig(
            embedScript: embedScript,
            baseUrl: "https://widgets-test.trypair.ai",
            enableIframeMediaPermissions: false,
            enableDebugBridge: true
        )

        let html = PairAiHtmlShell.build(config)
        XCTAssertTrue(html.contains("__PAIR_AI_ASSISTANT_DEBUG__"))
    }
}
