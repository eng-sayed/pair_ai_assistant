const String kPairAiEmbedScript = r'''
<script>
      window.PairAiWidgetSettings = {
        position: 'left',
        type: 'standard',
        user_Id: 'Xepo205680',
        openAutomatically: true,
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
            widgetId: '01KV5D4WSMW463XF1HQMV9GMM7',
            baseUrl: BASE_URL,
          })
        }
      })(document, 'script')
    
</script>
''';

const String kPairAiBaseUrl = 'https://widgets-test.trypair.ai';
