/// JavaScript helpers injected into the HTML shell before the embed script.
enum PairAiEmbedScripts {
    /// Adds `allow="microphone; camera"` on dynamically created iframes.
    static let iframeMediaPermissionsJs = """
(function () {
  if (window.__PAIR_AI_ASSISTANT_IFRAME__) return;
  window.__PAIR_AI_ASSISTANT_IFRAME__ = true;

  function post(type, payload) {
    try {
      var message = JSON.stringify({
        type: type,
        payload: payload || {},
        ts: new Date().toISOString()
      });
      if (window.PairAssistantDebug && window.PairAssistantDebug.postMessage) {
        window.PairAssistantDebug.postMessage(message);
      }
    } catch (e) {}
  }

  function addIframeMediaPermissions(iframe) {
    if (!iframe || !iframe.setAttribute) return;
    var currentAllow = iframe.getAttribute('allow') || '';
    var needed = ['microphone', 'camera'];
    var updated = currentAllow;
    needed.forEach(function (feature) {
      if (updated.indexOf(feature) === -1) {
        var separator = updated.trim() ? '; ' : '';
        updated = updated + separator + feature;
      }
    });
    if (updated !== currentAllow) {
      iframe.setAttribute('allow', updated);
      post('iframe:allow-media', {
        src: iframe.src || '',
        allow: iframe.getAttribute('allow')
      });
    }
  }

  document.querySelectorAll('iframe').forEach(addIframeMediaPermissions);
  var observer = new MutationObserver(function (mutations) {
    mutations.forEach(function (mutation) {
      mutation.addedNodes.forEach(function (node) {
        if (node && node.tagName === 'IFRAME') {
          addIframeMediaPermissions(node);
        }
        if (node && node.querySelectorAll) {
          node.querySelectorAll('iframe').forEach(addIframeMediaPermissions);
        }
      });
    });
  });
  observer.observe(document.documentElement, {
    childList: true,
    subtree: true
  });
})();

"""

    /// Optional debug bridge posted to `PairAssistantDebug` JavaScript channel.
    static let debugBridgeJs = """
(function () {
  if (window.__PAIR_AI_ASSISTANT_DEBUG__) return;
  window.__PAIR_AI_ASSISTANT_DEBUG__ = true;

  function safeString(value) {
    try {
      if (value == null) return String(value);
      if (typeof value === 'string') return value;
      if (value && value.message) return value.message;
      return JSON.stringify(value);
    } catch (e) {
      return Object.prototype.toString.call(value);
    }
  }

  function post(type, payload) {
    try {
      var message = JSON.stringify({
        type: type,
        payload: payload || {},
        ts: new Date().toISOString()
      });
      if (window.PairAssistantDebug && window.PairAssistantDebug.postMessage) {
        window.PairAssistantDebug.postMessage(message);
      } else {
        console.log('[PairAssistantDebug] ' + message);
      }
    } catch (e) {}
  }

  function summarizeValue(value) {
    if (typeof File !== 'undefined' && value instanceof File) {
      return {
        type: 'File',
        name: value.name,
        mimeType: value.type,
        size: value.size
      };
    }
    if (typeof Blob !== 'undefined' && value instanceof Blob) {
      return {
        type: 'Blob',
        mimeType: value.type,
        size: value.size
      };
    }
    if (typeof value === 'string') {
      return {
        type: 'String',
        length: value.length,
        preview: value.slice(0, 300)
      };
    }
    return {
      type: Object.prototype.toString.call(value)
    };
  }

  function summarizeBody(body) {
    if (!body) return null;
    try {
      if (typeof FormData !== 'undefined' && body instanceof FormData) {
        var fields = [];
        body.forEach(function (value, key) {
          fields.push({
            key: key,
            value: summarizeValue(value)
          });
        });
        return {
          type: 'FormData',
          fields: fields
        };
      }
      return summarizeValue(body);
    } catch (e) {
      return {
        type: 'Unknown',
        error: safeString(e)
      };
    }
  }

  function getUrl(input) {
    if (typeof input === 'string') return input;
    if (input && input.url) return input.url;
    return safeString(input);
  }

  function getMethod(input, init) {
    return (init && init.method) || (input && input.method) || 'GET';
  }

  function installMediaDevicesDebug() {
    post('media:capabilities', {
      isSecureContext: window.isSecureContext,
      hasMediaDevices: !!(navigator.mediaDevices),
      hasGetUserMedia: !!(navigator.mediaDevices && navigator.mediaDevices.getUserMedia)
    });

    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) return;

    var originalGetUserMedia = navigator.mediaDevices.getUserMedia.bind(
      navigator.mediaDevices
    );
    navigator.mediaDevices.getUserMedia = function (constraints) {
      post('media:get-user-media:start', {
        constraints: constraints
      });
      return originalGetUserMedia(constraints).then(function (stream) {
        post('media:get-user-media:success', {
          audioTracks: stream.getAudioTracks().length,
          videoTracks: stream.getVideoTracks().length
        });
        return stream;
      }).catch(function (error) {
        post('media:get-user-media:error', {
          name: error && error.name,
          message: error && error.message
        });
        throw error;
      });
    };
  }

  function responsePreview(response) {
    var contentType = response.headers && response.headers.get
      ? response.headers.get('content-type')
      : null;

    return response.clone().text().then(function (text) {
      return {
        contentType: contentType,
        length: text.length,
        preview: text.slice(0, 1000)
      };
    }).catch(function (error) {
      return {
        contentType: contentType,
        error: safeString(error)
      };
    });
  }

  window.addEventListener('error', function (event) {
    post('js:error', {
      message: event.message,
      source: event.filename,
      line: event.lineno,
      column: event.colno
    });
  });

  window.addEventListener('unhandledrejection', function (event) {
    post('js:unhandledrejection', {
      reason: safeString(event.reason)
    });
  });

  var originalFetch = window.fetch;
  if (originalFetch) {
    window.fetch = function (input, init) {
      var url = getUrl(input);
      var method = getMethod(input, init);
      post('fetch:start', {
        method: method,
        url: url,
        body: summarizeBody(init && init.body)
      });

      return originalFetch.apply(this, arguments).then(function (response) {
        responsePreview(response).then(function (preview) {
          post('fetch:response', {
            method: method,
            url: response.url || url,
            status: response.status,
            ok: response.ok,
            response: preview
          });
        });
        return response;
      }).catch(function (error) {
        post('fetch:error', {
          method: method,
          url: url,
          error: safeString(error)
        });
        throw error;
      });
    };
  }

  var XHR = window.XMLHttpRequest;
  if (XHR && XHR.prototype) {
    var originalOpen = XHR.prototype.open;
    var originalSend = XHR.prototype.send;

    XHR.prototype.open = function (method, url) {
      this.__pairAiAssistantDebugRequest = {
        method: method,
        url: url
      };
      return originalOpen.apply(this, arguments);
    };

    XHR.prototype.send = function (body) {
      var xhr = this;
      var request = xhr.__pairAiAssistantDebugRequest || {};
      post('xhr:start', {
        method: request.method || 'GET',
        url: request.url || '',
        body: summarizeBody(body)
      });

      function previewResponse() {
        try {
          if (xhr.responseType && xhr.responseType !== 'text') {
            return {
              responseType: xhr.responseType
            };
          }
          var text = xhr.responseText || '';
          return {
            length: text.length,
            preview: text.slice(0, 1000)
          };
        } catch (e) {
          return {
            error: safeString(e)
          };
        }
      }

      xhr.addEventListener('loadend', function () {
        post('xhr:response', {
          method: request.method || 'GET',
          url: xhr.responseURL || request.url || '',
          status: xhr.status,
          response: previewResponse()
        });
      });
      xhr.addEventListener('error', function () {
        post('xhr:error', {
          method: request.method || 'GET',
          url: request.url || '',
          status: xhr.status
        });
      });
      xhr.addEventListener('timeout', function () {
        post('xhr:timeout', {
          method: request.method || 'GET',
          url: request.url || ''
        });
      });

      return originalSend.apply(this, arguments);
    };
  }

  installMediaDevicesDebug();
  post('debug:installed');
})();

"""

    /// Re-applies Arabic font CSS in the document and child iframes.
    static let arabicFontFixJs = """
(function () {
  var css = "*{font-family:'Noto Sans Arabic','Geeza Pro','Baghdad','Damascus','Arial Unicode MS',Tahoma,'Helvetica Neue',Helvetica,-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,ui-sans-serif,system-ui,sans-serif!important;}input,textarea,[contenteditable='true']{font-family:inherit!important;}";
  function add(doc) {
    if (!doc || !doc.head) return;
    var id = 'pair-ai-assistant-ar-font-fix';
    var old = doc.getElementById(id);
    if (old) old.remove();
    var s = doc.createElement('style');
    s.id = id;
    s.textContent = css;
    doc.head.appendChild(s);
  }
  add(document);
  document.querySelectorAll('iframe').forEach(function (f) {
    try { add(f.contentDocument); } catch (e) {}
  });
})();

"""
}
