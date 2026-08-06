package ai.trypair.assistant

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class PairAiEmbedConfigTest {

    @Test(expected = IllegalArgumentException::class)
    fun emptyEmbedScriptThrows() {
        PairAiEmbedConfig.create(embedScript = "   ", baseUrl = "https://example.com")
    }

    @Test(expected = IllegalArgumentException::class)
    fun invalidBaseUrlThrows() {
        PairAiEmbedConfig.create(embedScript = "<script></script>", baseUrl = "ftp://x")
    }

    @Test(expected = IllegalArgumentException::class)
    fun invalidHtmlLangThrows() {
        PairAiEmbedConfig.create(
            embedScript = "<script></script>",
            baseUrl = "https://example.com",
            htmlLang = "ar\"><script>alert(1)</script>",
        )
    }

    @Test
    fun validConfigStoresFields() {
        val config = PairAiEmbedConfig.create(
            embedScript = "<script>ok</script>",
            baseUrl = "https://widgets-test.trypair.ai",
            enableDebugBridge = true,
        )

        assertEquals("<script>ok</script>", config.embedScript)
        assertEquals("https://widgets-test.trypair.ai", config.baseUrl)
        assertTrue(config.enableDebugBridge)
        assertTrue(config.allowedNavigationOrigins.contains("https://widgets-test.trypair.ai"))
    }

    @Test
    fun customAllowedNavigationOriginsAreStored() {
        val config = PairAiEmbedConfig.create(
            embedScript = "<script>ok</script>",
            baseUrl = "https://widgets-test.trypair.ai",
            allowedNavigationOrigins = listOf(
                "https://widgets.trypair.ai",
                "https://cdn.trypair.ai",
            ),
        )

        assertEquals(3, config.allowedNavigationOrigins.size)
        assertTrue(config.allowedNavigationOrigins.contains("https://widgets-test.trypair.ai"))
        assertTrue(config.allowedNavigationOrigins.contains("https://widgets.trypair.ai"))
    }

    @Test
    fun builderProducesValidatedConfig() {
        val config = PairAiEmbedConfig.Builder()
            .embedScript("<script>ok</script>")
            .baseUrl("https://widgets-test.trypair.ai")
            .enableDebugBridge(true)
            .build()

        assertTrue(config.enableDebugBridge)
    }
}
