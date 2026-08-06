package ai.trypair.assistant

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

/** Full-screen host activity for a Pair AI embed (mirrors Flutter PairAiWidgetScreen). */
class PairAiActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val config = intent.getParcelableExtra(EXTRA_CONFIG, PairAiEmbedConfig::class.java)
            ?: error("PairAiEmbedConfig extra is required")

        if (config.resizeToAvoidBottomInset) {
            window.setSoftInputMode(android.view.WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE)
        }

        val webView = PairAiWebView(
            context = this,
            config = config,
            host = this,
        )
        setContentView(webView)
    }

    companion object {
        private const val EXTRA_CONFIG = "ai.trypair.assistant.extra.CONFIG"

        /** Creates an [Intent] that launches [PairAiActivity] with [config]. */
        @JvmStatic
        fun newIntent(context: Context, config: PairAiEmbedConfig): Intent {
            return Intent(context, PairAiActivity::class.java).apply {
                putExtra(EXTRA_CONFIG, config)
            }
        }
    }
}
