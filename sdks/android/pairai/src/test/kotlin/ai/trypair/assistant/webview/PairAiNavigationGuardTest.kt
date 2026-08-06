package ai.trypair.assistant.webview

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class PairAiNavigationGuardTest {

    private lateinit var guard: PairAiNavigationGuard

    @Before
    fun setUp() {
        guard = PairAiNavigationGuard(
            setOf("https://widgets-test.trypair.ai"),
        )
    }

    @Test
    fun allowsSameOriginHttpsNavigation() {
        assertTrue(guard.isAllowed("https://widgets-test.trypair.ai/sdk.js"))
    }

    @Test
    fun allowsAboutBlank() {
        assertTrue(guard.isAllowed("about:blank"))
    }

    @Test
    fun blocksJavascriptScheme() {
        assertFalse(guard.isAllowed("javascript:alert(1)"))
    }

    @Test
    fun blocksForeignOrigins() {
        assertFalse(guard.isAllowed("https://evil.example/phish"))
    }

    @Test
    fun blocksInvalidUrls() {
        assertFalse(guard.isAllowed("not a url"))
    }
}
