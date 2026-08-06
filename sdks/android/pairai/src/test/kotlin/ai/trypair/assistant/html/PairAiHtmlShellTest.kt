package ai.trypair.assistant.html

import ai.trypair.assistant.PairAiEmbedConfig
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import java.nio.charset.StandardCharsets

@RunWith(RobolectricTestRunner::class)
class PairAiHtmlShellTest {

    @Test
    fun embedScripts_constantsAreNonEmpty() {
        assertTrue(PairAiEmbedScripts.iframeMediaPermissionsJs.contains("__PAIR_AI_ASSISTANT_IFRAME__"))
        assertTrue(PairAiEmbedScripts.debugBridgeJs.contains("__PAIR_AI_ASSISTANT_DEBUG__"))
        assertTrue(PairAiEmbedScripts.arabicFontFixJs.contains("pair-ai-assistant-ar-font-fix"))
    }

    @Test
    fun build_includesDebugBridgeWhenEnabled() {
        val config = PairAiEmbedConfig.create(
            embedScript = EMBED_SCRIPT,
            baseUrl = "https://widgets-test.trypair.ai",
            enableDebugBridge = true,
            enableIframeMediaPermissions = true,
        )
        val html = PairAiHtmlShell.build(config)
        assertTrue(html.contains("__PAIR_AI_ASSISTANT_DEBUG__"))
    }

    @Test
    fun build_matchesDartGoldenFixture() {
        val config = PairAiEmbedConfig.create(
            embedScript = EMBED_SCRIPT,
            baseUrl = "https://widgets-test.trypair.ai",
            enableArabicFontFix = true,
            enableDebugBridge = false,
            enableIframeMediaPermissions = true,
            htmlLang = "ar",
        )

        val html = PairAiHtmlShell.build(config)
        val golden = readGoldenFixture()

        assertEquals(golden, html)
    }

    @Test
    fun build_omitsDebugBridgeWhenDisabled() {
        val config = PairAiEmbedConfig.create(
            embedScript = EMBED_SCRIPT,
            baseUrl = "https://widgets-test.trypair.ai",
            enableDebugBridge = false,
            enableIframeMediaPermissions = false,
        )

        val html = PairAiHtmlShell.build(config)

        assertTrue(html.contains("<!DOCTYPE html>"))
        assertTrue(html.contains("<html lang=\"ar\">"))
        assertTrue(html.contains(EMBED_SCRIPT))
        assertTrue(html.contains("Noto+Sans+Arabic"))
        assertTrue(!html.contains("__PAIR_AI_ASSISTANT_DEBUG__"))
    }

    private fun readGoldenFixture(): String {
        val stream = checkNotNull(javaClass.classLoader.getResourceAsStream("html_shell_golden.html")) {
            "Missing html_shell_golden.html test resource"
        }
        return stream.bufferedReader(StandardCharsets.UTF_8).use { it.readText() }
    }

    companion object {
        private const val EMBED_SCRIPT = "<script>window.PairAiWidgetSettings = {}</script>"
    }
}
