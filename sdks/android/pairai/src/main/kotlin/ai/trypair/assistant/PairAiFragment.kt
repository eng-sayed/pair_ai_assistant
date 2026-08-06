package ai.trypair.assistant

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment

/** Fragment wrapper that provides an [ActivityResultCaller] host for [PairAiWebView]. */
class PairAiFragment : Fragment() {

    private var config: PairAiEmbedConfig? = null
    private var onDebugLog: ((String) -> Unit)? = null
    private var onPageFinished: ((String) -> Unit)? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        config = arguments?.getParcelable(ARG_CONFIG, PairAiEmbedConfig::class.java)
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View {
        val embedConfig = config ?: error("PairAiEmbedConfig argument is required")
        return PairAiWebView(
            context = requireContext(),
            config = embedConfig,
            host = this,
            onDebugLog = onDebugLog,
            onPageFinished = onPageFinished,
        )
    }

    companion object {
        private const val ARG_CONFIG = "ai.trypair.assistant.arg.CONFIG"

        /** Creates a [PairAiFragment] for [config]. */
        @JvmStatic
        fun newInstance(
            config: PairAiEmbedConfig,
            onDebugLog: ((String) -> Unit)? = null,
            onPageFinished: ((String) -> Unit)? = null,
        ): PairAiFragment {
            return PairAiFragment().apply {
                arguments = Bundle().apply {
                    putParcelable(ARG_CONFIG, config)
                }
                this.onDebugLog = onDebugLog
                this.onPageFinished = onPageFinished
            }
        }
    }
}
