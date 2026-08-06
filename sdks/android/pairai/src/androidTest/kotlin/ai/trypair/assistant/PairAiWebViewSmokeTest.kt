package ai.trypair.assistant

import androidx.test.ext.junit.rules.ActivityScenarioRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.filters.LargeTest
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

@RunWith(AndroidJUnit4::class)
@LargeTest
class PairAiWebViewSmokeTest {

  private val config = PairAiEmbedConfig.create(
        embedScript = "<html><body>Pair AI smoke test</body></html>",
        baseUrl = "https://widgets-test.trypair.ai",
        enableDebugBridge = false,
        enableIframeMediaPermissions = false,
        enableArabicFontFix = false,
    )

    @get:Rule
    val activityRule = ActivityScenarioRule(TestHostActivity::class.java)

    @Test
    fun webViewFiresOnPageFinished() {
        val latch = CountDownLatch(1)
        var finishedUrl = ""

        activityRule.scenario.onActivity { activity ->
            val webView = PairAiWebView(
                context = activity,
                config = config,
                host = activity,
                onPageFinished = { url ->
                    finishedUrl = url
                    latch.countDown()
                },
            )
            activity.setContentView(webView)
        }

        assertTrue(latch.await(15, TimeUnit.SECONDS))
        assertTrue(finishedUrl.isNotEmpty())
    }
}
