package ai.trypair.assistant

import org.json.JSONArray
import org.json.JSONObject

/** A widget event forwarded from the WebView to the host app. */
data class PairAiWidgetEvent(
    val type: String,
    val data: Map<String, Any?>,
    val origin: String,
    val timestamp: String,
) {
    companion object {
        /** Parses a JSON payload posted on the `PairAssistantEvents` channel. */
        @JvmStatic
        fun tryParse(message: String): PairAiWidgetEvent? {
            return try {
                val root = JSONObject(message)
                val type = root.optString("type", "")
                if (type.isEmpty()) {
                    return null
                }
                PairAiWidgetEvent(
                    type = type,
                    data = jsonToMap(root.optJSONObject("data")),
                    origin = root.optString("origin", ""),
                    timestamp = root.optString("ts", ""),
                )
            } catch (_: Exception) {
                null
            }
        }

        private fun jsonToMap(obj: JSONObject?): Map<String, Any?> {
            if (obj == null) {
                return emptyMap()
            }
            val map = linkedMapOf<String, Any?>()
            val keys = obj.keys()
            while (keys.hasNext()) {
                val key = keys.next()
                map[key] = unwrap(obj.get(key))
            }
            return map
        }

        private fun unwrap(value: Any?): Any? {
            return when (value) {
                null, JSONObject.NULL -> null
                is JSONObject -> jsonToMap(value)
                is JSONArray -> (0 until value.length()).map { unwrap(value.get(it)) }
                else -> value
            }
        }
    }
}
