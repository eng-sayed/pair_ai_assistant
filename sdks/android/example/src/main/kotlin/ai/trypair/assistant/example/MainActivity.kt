package ai.trypair.assistant.example

import ai.trypair.assistant.PairAiEmbedConfig
import ai.trypair.assistant.PairAiWebView
import ai.trypair.assistant.PairAiWidgetEvent
import android.graphics.Typeface
import android.os.Bundle
import android.util.Log
import android.util.TypedValue
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.setPadding

class MainActivity : AppCompatActivity() {
    private var pairView: PairAiWebView? = null
    private lateinit var eventLabel: TextView
    private lateinit var sendButton: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(16))
        }

        eventLabel = TextView(this).apply {
            text = "No event yet"
            typeface = Typeface.MONOSPACE
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
        }
        root.addView(
            eventLabel,
            LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            ),
        )

        sendButton = Button(this).apply {
            text = "Send window.postMessage"
            isEnabled = false
            setOnClickListener { sendPostMessage() }
        }
        root.addView(
            sendButton,
            LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            ).apply { topMargin = dp(12) },
        )

        val config = PairAiEmbedConfig.create(
            embedScript = PAIR_AI_EMBED_SCRIPT,
            baseUrl = PAIR_AI_BASE_URL,
            enableDebugBridge = true,
        )
        val pairView = PairAiWebView(
            context = this,
            config = config,
            host = this,
            onDebugLog = { log -> Log.d("PairAiDebug", log) },
            onPageFinished = {
                runOnUiThread { sendButton.isEnabled = true }
            },
            onEvent = { event ->
                runOnUiThread { showEvent(event) }
            },
        )
        this.pairView = pairView
        root.addView(
            pairView,
            LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                0,
                1f,
            ).apply { topMargin = dp(12) },
        )

        setContentView(root)
    }

    private fun sendPostMessage() {
        pairView?.webView?.evaluateJavascript(POST_MESSAGE_JS, null)
    }

    private fun showEvent(event: PairAiWidgetEvent) {
        Log.d("PairAiEvent", "${event.type} ${event.data}")
        eventLabel.text = "${event.type}\n${event.data}"
    }

    private fun dp(value: Int): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            value.toFloat(),
            resources.displayMetrics,
        ).toInt()
    }

    companion object {
        /**
         * Same-window `postMessage` used by the demo button.
         * The HTML shell already listens and forwards `widget:` / `form:` payloads to `onEvent`.
         */
        private const val POST_MESSAGE_JS = """
            window.postMessage({
              type: 'widget:demo',
              message: 'Hello from window.postMessage'
            }, window.location.origin);
        """
    }
}
