package ai.trypair.assistant.example

const val PAIR_AI_BASE_URL = "https://widgets-test.trypair.ai"

/** Pair embed script used to exercise `onEvent` against widgets-test. */
const val PAIR_AI_EMBED_SCRIPT = """
<script>
      window.PairAiWidgetSettings = {
        position: 'right',
        type: 'expanded_bubble',
        launcherTitle: 'Chat with us',
      }
      ;(function (d, t) {
        var BASE_URL = 'https://widgets-test.trypair.ai'
        var g = d.createElement(t),
          s = d.getElementsByTagName(t)[0]
        g.src = BASE_URL + '/sdk.js'
        g.async = true
        s.parentNode.insertBefore(g, s)
        g.onload = function () {
          window.PairAiWidgetSDK.run({
            widgetId: '01KX2WEEF10SJ1ET7QNMA9XFJV',
            baseUrl: BASE_URL,
          })
        }
      })(document, 'script')
</script>
"""
