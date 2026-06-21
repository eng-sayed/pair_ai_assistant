/// Replace with values from the Pair dashboard before running the example.
const String kPairAiUserId = 'YOUR_USER_ID';
const String kPairAiWidgetId = 'YOUR_WIDGET_ID';
const String kPairAiBaseUrl = 'https://widgets-test.trypair.ai';

/// Pair embed script with placeholder credentials for the example app.
String get kPairAiEmbedScript => '''
<script>
      window.PairAiWidgetSettings = {
        position: 'left',
        type: 'standard',
        user_Id: '$kPairAiUserId',
        openAutomatically: true,
      }
      ;(function (d, t) {
        var BASE_URL = '$kPairAiBaseUrl'
        var g = d.createElement(t),
          s = d.getElementsByTagName(t)[0]
        g.src = BASE_URL + '/sdk.js'
        g.async = true
        s.parentNode.insertBefore(g, s)
        g.onload = function () {
          window.PairAiWidgetSDK.run({
            widgetId: '$kPairAiWidgetId',
            baseUrl: BASE_URL,
          })
        }
      })(document, 'script')

</script>
''';
