import 'dart:async';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../android/pair_ai_android_file_selector.dart';
import '../config/pair_ai_embed_config.dart';
import '../events/pair_ai_widget_event.dart';
import '../html/pair_ai_embed_scripts.dart';
import '../html/pair_ai_html_shell.dart';
import '../utils/pair_ai_logger.dart';
import '../utils/pair_ai_navigation_guard.dart';
import 'pair_ai_permission_handler.dart';

/// Creates and configures a [WebViewController] for Pair AI embeds.
class PairAiWebViewFactory {
  PairAiWebViewFactory({
    required this.config,
    required this.logger,
    required this.onPageFinished,
    this.onEvent,
    PairAiPermissionHandler? permissionHandler,
    PairAiAndroidFileSelector? androidFileSelector,
  })  : _permissionHandler =
            permissionHandler ?? PairAiPermissionHandler(logger),
        _androidFileSelector =
            androidFileSelector ?? PairAiAndroidFileSelector(logger: logger);

  final PairAiEmbedConfig config;
  final PairAiLogger logger;
  final void Function(String url) onPageFinished;
  final void Function(PairAiWidgetEvent event)? onEvent;
  final PairAiPermissionHandler _permissionHandler;
  final PairAiAndroidFileSelector _androidFileSelector;
  bool _disposed = false;

  /// Cancels pending deferred work such as Arabic font re-injection.
  void dispose() {
    _disposed = true;
  }

  /// Builds a configured [WebViewController].
  WebViewController create() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(
      params,
      onPermissionRequest: _permissionHandler.handle,
    );

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    if (config.userAgent != null) {
      unawaited(controller.setUserAgent(config.userAgent));
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(config.backgroundColor);

    if (config.enableDebugBridge) {
      controller
        ..addJavaScriptChannel(
          'PairAssistantDebug',
          onMessageReceived: (JavaScriptMessage message) {
            logger.log(message.message);
          },
        )
        ..setOnConsoleMessage(
          (JavaScriptConsoleMessage message) {
            logger.log('console:${message.level.name}: ${message.message}');
          },
        );
    }

    final bool enableEventBridge = config.enableEventBridge || onEvent != null;
    if (enableEventBridge) {
      controller.addJavaScriptChannel(
        'PairAssistantEvents',
        onMessageReceived: (JavaScriptMessage message) {
          final PairAiWidgetEvent? event =
              PairAiWidgetEvent.tryParse(message.message);
          if (event == null) {
            return;
          }
          onEvent?.call(event);
        },
      );
    }

    final PairAiNavigationGuard navigationGuard = PairAiNavigationGuard(
      config.allowedNavigationOrigins,
    );

    controller.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          if (!config.restrictNavigation ||
              navigationGuard.isAllowed(request.url)) {
            return NavigationDecision.navigate;
          }
          logger.log('navigation:blocked: ${request.url}');
          return NavigationDecision.prevent;
        },
        onPageStarted: (String url) => logger.log('page:start: $url'),
        onPageFinished: (String url) {
          logger.log('page:finished: $url');
          onPageFinished(url);
          _scheduleArabicFontFix(controller);
        },
        onHttpError: (HttpResponseError error) {
          logger.log(
            'http:error: url=${error.response?.uri ?? error.request?.uri} '
            'status=${error.response?.statusCode}',
          );
        },
        onWebResourceError: (WebResourceError error) {
          logger.log(
            'resource:error: url=${error.url} '
            'code=${error.errorCode} '
            'type=${error.errorType} '
            'description=${error.description}',
          );
        },
      ),
    );

    final String html = PairAiHtmlShell.build(
      config,
      enableEventBridge: enableEventBridge,
    );
    controller.loadHtmlString(html, baseUrl: config.baseUrl);

    return controller;
  }

  /// Configures Android-only bridges after the controller is attached.
  Future<void> configurePlatform(WebViewController controller) async {
    if (controller.platform is AndroidWebViewController) {
      final AndroidWebViewController androidController =
          controller.platform as AndroidWebViewController;
      await androidController.setAllowFileAccess(true);
      await androidController.setAllowContentAccess(true);
      await androidController.setOnShowFileSelector(_androidFileSelector.handle);
      logger.log('android:file-selector:configured');
      return;
    }

    if (controller.platform is WebKitWebViewController) {
      logger.log('ios:file-selector:native-wkwebview');
    }
  }

  void _scheduleArabicFontFix(WebViewController controller) {
    if (!config.enableArabicFontFix) {
      return;
    }

    void inject() {
      if (_disposed) {
        return;
      }
      unawaited(
        controller.runJavaScript(PairAiEmbedScripts.arabicFontFixJs),
      );
    }

    inject();
    Future<void>.delayed(const Duration(milliseconds: 300), inject);
    Future<void>.delayed(const Duration(milliseconds: 1500), inject);
    Future<void>.delayed(const Duration(milliseconds: 4000), inject);
  }
}
