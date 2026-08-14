package ai.trypair.assistant.webview

import androidx.core.content.FileProvider

/** Host-app-scoped FileProvider so the SDK can coexist with other Pair AI apps. */
class PairAiFileProvider : FileProvider()
