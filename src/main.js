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

function gifURL(url) {
  var gif = undefined
  var matches = RegExp('^https://giphy.com/gifs/.+-([^-\n]+)$').exec(url)
  if (matches && matches.length == 2) {
    var identifier = matches[1]
    gif = 'https://media.giphy.com/media/' + identifier + '/giphy.gif'
  }
  return gif
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
    'copyURL:': {
      types: ['void', ['id']],
      implementation: function(sender) {
        var url = gifURL(webView.URL.description.js)
        if (url) {
          $.NSPasteboard.generalPasteboard.clearContents
          $.NSPasteboard.generalPasteboard.writeObjects($([url]))
        }
        else {
          statusItem.button.performClick(this)
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
          statusItem.button.performClick(this)
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
