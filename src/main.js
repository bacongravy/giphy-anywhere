ObjC.import('Cocoa')
ObjC.import('WebKit')

// add ourselves to the Login Items

Application('System Events').LoginItem({path: $.NSBundle.mainBundle.bundlePath.js, hidden: false}).make()

// create web view

var webViewRect = $.NSMakeRect(0, 0, 360, 640)
var webViewCustomUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1"

var webViewConf = $.WKWebViewConfiguration.alloc.init
webViewConf.preferences.plugInsEnabled = true

var webView = $.WKWebView.alloc.initWithFrameConfiguration(webViewRect, webViewConf)
webView.customUserAgent = webViewCustomUserAgent

var url = $.NSURL.URLWithString('https://giphy.com/')
var req = $.NSURLRequest.requestWithURL(url)
webView.loadRequest(req)

var hideTrendingChannelsScript = `
  var h2Tags = document.getElementsByTagName('h2');
  var searchText = 'Trending Channels';
  var foundElement;
  for (var i = 0; i < h2Tags.length; i++) {
    if (h2Tags[i].textContent == searchText) {
      foundElement = h2Tags[i];
      break;
    }
  }
  if (foundElement) {
    foundElement.parentElement.parentElement.hidden = true;
  }
`

// create menu items

var webViewItem = $.NSMenuItem.alloc.init
webViewItem.view = webView

var copyURLItem = $.NSMenuItem.alloc.init
copyURLItem.title = 'Copy GIF URL'

var copyMarkdownItem = $.NSMenuItem.alloc.init
copyMarkdownItem.title = 'Copy GIF URL (GitHub Markdown)'

var quitItem = $.NSMenuItem.alloc.init
quitItem.title = 'Quit'

var statusMenu = $.NSMenu.alloc.init
statusMenu.addItem(webViewItem)
statusMenu.addItem($.NSMenuItem.separatorItem)
statusMenu.addItem(copyURLItem)
statusMenu.addItem(copyMarkdownItem)
statusMenu.addItem($.NSMenuItem.separatorItem)
statusMenu.addItem(quitItem)

// register controller class

function gifIdentifier(url) {
  var matches = RegExp('^https://giphy.com/gifs/(.*-)?([^-\n]+)$').exec(url)
  if (matches && matches.length == 3) {
    return matches[2]
  }
  return undefined
}

function gifURL(url) {
  var identifier = gifIdentifier(url)
  if (identifier) {
    return 'https://media.giphy.com/media/' + identifier + '/giphy.gif'
  }
  return undefined
}

ObjC.registerSubclass({
  name: 'StatusItemController',
  methods: {
    'popUpMenu:': {
      types: ['void', ['id']],
      implementation: function(sender) {
        if ($.NSApplication.sharedApplication.active) {
          statusItem.highlightMode = true
          statusItem.popUpStatusItemMenu(statusMenu)
          statusItem.highlightMode = false
        } else {
          $.NSApplication.sharedApplication.activateIgnoringOtherApps(true)
        }
      }
    },
    'validateMenuItem:': {
      types: ['BOOL', ['id']],
      implementation: function(sender) {
        if (sender.action == 'copyURL:' || sender.action == 'copyMarkdown:') {
          return gifIdentifier(webView.URL.description.js) != undefined
        }
        return true
      }
    },
    'becomeActive:': {
      types: ['void', ['id']],
      implementation: function(sender) {
        statusItem.button.performClick(this)
      }
    },
    'webView:didFinishNavigation:': {
      types: ['void', ['id', 'id']],
      implementation: function(webView, navigation) {
        webView.evaluateJavaScriptCompletionHandler(hideTrendingChannelsScript, function (result, error) {})
      }
    },
    'observeValueForKeyPath:ofObject:change:context:': {
      types: ['void', ['id', 'id', 'id', 'void *']],
      implementation: function(keyPath, object, change, context) {
        if (keyPath.isEqualToString('URL')) {
          var enabled = gifIdentifier(webView.URL.description.js) != undefined
          copyURLItem.enabled = enabled
          copyMarkdownItem.enabled = enabled
        }
      }
    },
    'copyURL:': {
      types: ['void', ['id']],
      implementation: function(sender) {
        var url = gifURL(webView.URL.description.js)
        if (url) {
          $.NSPasteboard.generalPasteboard.clearContents
          $.NSPasteboard.generalPasteboard.writeObjects($([url]))
        }
        else {
          $.NSBeep()
        }
      }
    },
    'copyMarkdown:': {
      types: ['void', ['id']],
      implementation: function(sender) {
        var url = gifURL(webView.URL.description.js)
        if (url) {
          var markdown = '![](' + url + ')'
          $.NSPasteboard.generalPasteboard.clearContents
          $.NSPasteboard.generalPasteboard.writeObjects($([markdown]))
        }
        else {
          $.NSBeep()
        }
      }
    },
    'quit:': {
      types: ['void', ['id']],
      implementation: function(sender) {
        Application('System Events').loginItems.whose({path: $.NSBundle.mainBundle.bundlePath.js}).first.delete()
        $.NSNotificationCenter.defaultCenter.removeObserver(statusItemController)
        $.NSApp.terminate($())
      }
    },
  }
})

// create controller

var statusItemController = $.StatusItemController.alloc.init

$.NSNotificationCenter.defaultCenter.addObserverSelectorNameObject(statusItemController, 'becomeActive:', $.NSApplicationDidBecomeActiveNotification, $.NSApp)

webView.navigationDelegate = statusItemController

webView.addObserverForKeyPathOptionsContext(statusItemController, 'URL', $.NSKeyValueObservingOptionNew, undefined)

// create status item to status bar

var statusItem = $.NSStatusBar.systemStatusBar.statusItemWithLength($.NSVariableStatusItemLength)

var giphyImage = $.NSImage.alloc.initWithContentsOfURL($.NSURL.URLWithString('https://giphy.com/favicon.ico'))

if (giphyImage.isNil()) {
  statusItem.button.title = "GIPHY Anywhere"
}
else {
  statusItem.button.image = giphyImage
}

// set controller as target of status item and menu items

statusItem.target = statusItemController
statusItem.action = 'popUpMenu:'
statusItem.highlightMode = false

copyURLItem.target = statusItemController
copyURLItem.action = 'copyURL:'

copyMarkdownItem.target = statusItemController
copyMarkdownItem.action = 'copyMarkdown:'

quitItem.target = statusItemController
quitItem.action = 'quit:'
