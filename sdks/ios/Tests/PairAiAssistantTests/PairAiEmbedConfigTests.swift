import XCTest
@testable import PairAiAssistant

final class PairAiEmbedConfigTests: XCTestCase {
    func testEmptyEmbedScriptThrows() {
        XCTAssertThrowsError(try PairAiEmbedConfig(embedScript: "   ", baseUrl: "https://example.com")) { error in
            XCTAssertEqual(error as? PairAiConfigError, .emptyEmbedScript)
        }
    }

    func testInvalidBaseUrlThrows() {
        XCTAssertThrowsError(
            try PairAiEmbedConfig(embedScript: "<script></script>", baseUrl: "ftp://x")
        ) { error in
            XCTAssertEqual(error as? PairAiConfigError, .invalidBaseUrl)
        }
    }

    func testInvalidHtmlLangThrows() {
        XCTAssertThrowsError(
            try PairAiEmbedConfig(
                embedScript: "<script></script>",
                baseUrl: "https://example.com",
                htmlLang: "ar\"><script>alert(1)</script>"
            )
        ) { error in
            XCTAssertEqual(error as? PairAiConfigError, .invalidHtmlLang)
        }
    }

    func testValidConfigStoresFields() throws {
        let config = try PairAiEmbedConfig(
            embedScript: "<script>ok</script>",
            baseUrl: "https://widgets-test.trypair.ai",
            enableDebugBridge: true
        )

        XCTAssertEqual(config.embedScript, "<script>ok</script>")
        XCTAssertEqual(config.baseUrl, "https://widgets-test.trypair.ai")
        XCTAssertTrue(config.enableDebugBridge)
        XCTAssertTrue(config.allowedNavigationOrigins.contains("https://widgets-test.trypair.ai"))
    }

    func testCustomAllowedNavigationOriginsAreStored() throws {
        let config = try PairAiEmbedConfig(
            embedScript: "<script>ok</script>",
            baseUrl: "https://widgets-test.trypair.ai",
            allowedNavigationOrigins: [
                "https://widgets.trypair.ai",
                "https://cdn.trypair.ai",
            ]
        )

        XCTAssertEqual(config.allowedNavigationOrigins.count, 3)
        XCTAssertTrue(config.allowedNavigationOrigins.contains("https://widgets-test.trypair.ai"))
        XCTAssertTrue(config.allowedNavigationOrigins.contains("https://widgets.trypair.ai"))
    }

    func testDefaultValuesMatchFlutter() throws {
        let config = try PairAiEmbedConfig(
            embedScript: "<script>ok</script>",
            baseUrl: "https://example.com"
        )

        XCTAssertTrue(config.enableArabicFontFix)
        XCTAssertTrue(config.enableIframeMediaPermissions)
        XCTAssertFalse(config.enableDebugBridge)
        XCTAssertEqual(config.debugLogTag, "PairAiAssistant")
        XCTAssertTrue(config.resizeToAvoidBottomInset)
        XCTAssertEqual(config.htmlLang, "ar")
        XCTAssertTrue(config.restrictNavigation)
        XCTAssertNil(config.userAgent)
        XCTAssertNil(config.extraHeadHtml)
    }
}
