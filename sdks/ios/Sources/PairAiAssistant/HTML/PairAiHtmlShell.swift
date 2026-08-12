import Foundation

/// Builds the HTML document that wraps a verbatim Pair embed script.
public enum PairAiHtmlShell {
    /// Generates a complete HTML page for [config].
    public static func build(_ config: PairAiEmbedConfig, enableEventBridge: Bool? = nil) -> String {
        var head = ""
        head += "<meta charset=\"utf-8\">\n"
        head += "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n"
        head += "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, "
        head += "maximum-scale=1.0, user-scalable=no\">\n"

        if config.enableArabicFontFix {
            head += "<link rel=\"preconnect\" href=\"https://fonts.googleapis.com\">\n"
            head += "<link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin>\n"
            head += "<link href=\"https://fonts.googleapis.com/css2?family=Noto+Sans+Arabic"
            head += ":wght@400;500;600;700&display=swap\" rel=\"stylesheet\">\n"
            head += "<style>\n"
            head += "html, body { margin: 0; padding: 0; height: 100%; background: #fff; }\n"
            head += "*, *::before, *::after {\n"
            head += "  font-family: 'Noto Sans Arabic', 'Geeza Pro', 'Baghdad',\n"
            head += "    'Damascus', 'Arial Unicode MS', Tahoma, 'Helvetica Neue',\n"
            head += "    Helvetica, -apple-system, BlinkMacSystemFont,\n"
            head += "    'Segoe UI', Roboto, ui-sans-serif, system-ui, sans-serif !important;\n"
            head += "}\n"
            head += "</style>\n"
        } else {
            head += "<style>html, body { margin: 0; padding: 0; height: 100%; }</style>\n"
        }

        if let extraHeadHtml = config.extraHeadHtml {
            head += extraHeadHtml + "\n"
        }

        let injectEvents = enableEventBridge ?? config.enableEventBridge
        var bodyPrefix = ""
        if config.enableDebugBridge || config.enableIframeMediaPermissions || injectEvents {
            bodyPrefix += "<script>\n"
            if config.enableIframeMediaPermissions {
                bodyPrefix += PairAiEmbedScripts.iframeMediaPermissionsJs
            }
            if config.enableDebugBridge {
                bodyPrefix += PairAiEmbedScripts.debugBridgeJs
            }
            if injectEvents {
                bodyPrefix += PairAiEmbedScripts.eventBridgeJs(
                    allowedOrigins: Array(config.allowedNavigationOrigins)
                )
            }
            bodyPrefix += "\n</script>\n"
        }

        return """
<!DOCTYPE html>
<html lang="\(config.htmlLang)">
<head>
\(head)
</head>
<body>
\(bodyPrefix)\(config.embedScript)
</body>
</html>

"""
    }
}
