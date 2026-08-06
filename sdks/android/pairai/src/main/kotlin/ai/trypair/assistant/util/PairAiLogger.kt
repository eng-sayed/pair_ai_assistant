package ai.trypair.assistant.util

import ai.trypair.assistant.PairAiEmbedConfig

/** Internal logger for [PairAiEmbedConfig.debugLogTag]. */
class PairAiLogger(
    private val config: PairAiEmbedConfig,
    private val onDebugLog: ((String) -> Unit)? = null,
) {
    fun log(message: String) {
        val formatted = "[${config.debugLogTag}] $message"
        android.util.Log.d(config.debugLogTag, message)
        onDebugLog?.invoke(formatted)
    }
}
