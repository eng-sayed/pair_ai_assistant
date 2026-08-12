package ai.trypair.assistant.html

import ai.trypair.assistant.PairAiEmbedConfig

/** Builds the HTML document that wraps a verbatim Pair embed script. */
object PairAiHtmlShell {
    /** Generates a complete HTML page for [config]. */
    @JvmOverloads
    fun build(config: PairAiEmbedConfig, enableEventBridge: Boolean = config.enableEventBridge): String {
        val head = StringBuilder()
            .appendLine("<meta charset=\"utf-8\">")
            .appendLine("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">")
            .appendLine(
                "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, " +
                    "maximum-scale=1.0, user-scalable=no\">",
            )

        if (config.enableArabicFontFix) {
            head
                .appendLine("<link rel=\"preconnect\" href=\"https://fonts.googleapis.com\">")
                .appendLine(
                    "<link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin>",
                )
                .appendLine(
                    "<link href=\"https://fonts.googleapis.com/css2?family=Noto+Sans+Arabic" +
                        ":wght@400;500;600;700&display=swap\" rel=\"stylesheet\">",
                )
                .appendLine("<style>")
                .appendLine("html, body { margin: 0; padding: 0; height: 100%; background: #fff; }")
                .appendLine("*, *::before, *::after {")
                .appendLine("  font-family: 'Noto Sans Arabic', 'Geeza Pro', 'Baghdad',")
                .appendLine("    'Damascus', 'Arial Unicode MS', Tahoma, 'Helvetica Neue',")
                .appendLine("    Helvetica, -apple-system, BlinkMacSystemFont,")
                .appendLine("    'Segoe UI', Roboto, ui-sans-serif, system-ui, sans-serif !important;")
                .appendLine("}")
                .appendLine("</style>")
        } else {
            head.appendLine("<style>html, body { margin: 0; padding: 0; height: 100%; }</style>")
        }

        config.extraHeadHtml?.let { head.appendLine(it) }

        val injectEvents = enableEventBridge
        val bodyPrefix = StringBuilder()
        if (config.enableDebugBridge || config.enableIframeMediaPermissions || injectEvents) {
            bodyPrefix.appendLine("<script>")
            if (config.enableIframeMediaPermissions) {
                bodyPrefix.append(PairAiEmbedScripts.iframeMediaPermissionsJs)
            }
            if (config.enableDebugBridge) {
                bodyPrefix.append(PairAiEmbedScripts.debugBridgeJs)
            }
            if (injectEvents) {
                bodyPrefix.append(PairAiEmbedScripts.eventBridgeJs(config.allowedNavigationOrigins))
            }
            bodyPrefix.append("\n</script>\n")
        }

        return """<!DOCTYPE html>
<html lang="${config.htmlLang}">
<head>
$head
</head>
<body>
$bodyPrefix${config.embedScript}
</body>
</html>
"""
    }
}
