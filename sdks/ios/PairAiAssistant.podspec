Pod::Spec.new do |s|
  s.name             = 'PairAiAssistant'
  s.version          = '0.1.0'
  s.summary          = 'Native iOS SDK for embedding Pair AI assistant widgets in WKWebView.'
  s.description      = 'Swift SDK that mirrors the pair_ai_assistant Flutter package: HTML shell, navigation guard, media permissions, and debug bridge.'
  s.homepage         = 'https://github.com/trypair/pair_ai_assistant'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Pair' => 'support@trypair.ai' }
  s.source           = { :git => 'https://github.com/trypair/pair_ai_assistant.git', :tag => s.version.to_s }
  s.ios.deployment_target = '15.0'
  s.swift_version    = '5.9'
  s.source_files     = 'Sources/PairAiAssistant/**/*.swift'
end
