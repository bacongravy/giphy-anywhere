#!/usr/bin/swift

import Cocoa
import WebKit
import ServiceManagement

let sharedApplication = NSApplication.shared

let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

let giphyImage = NSImage.init(byReferencing: URL.init(string: "https://giphy.com/favicon.ico")!)

if (!giphyImage.isValid) {
    statusItem.button?.title = "GIPHY Anywhere"
}
else {
    statusItem.button?.image = giphyImage
}

let webViewRect = NSMakeRect(0, 0, 360, 640)
let webViewCustomUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1"

let webViewConf = WKWebViewConfiguration.init()
webViewConf.preferences.plugInsEnabled = true

let theWebView = WKWebView.init(frame: webViewRect, configuration: webViewConf)
theWebView.customUserAgent = webViewCustomUserAgent

let url = URL.init(string: "https://giphy.com/")
let req = URLRequest.init(url: url!)
theWebView.load(req)

let hideTrendingChannelsScript = """
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
    """


let webViewItem = NSMenuItem.init()
webViewItem.view = theWebView

let copyURLItem = NSMenuItem.init()
copyURLItem.title = "Copy GIF URL"

let copyMarkdownItem = NSMenuItem.init()
copyMarkdownItem.title = "Copy GIF URL (GitHub Markdown)"

let quitItem = NSMenuItem.init()
quitItem.title = "Quit"

let statusMenu = NSMenu.init()
statusMenu.addItem(webViewItem)
statusMenu.addItem(NSMenuItem.separator())
statusMenu.addItem(copyURLItem)
statusMenu.addItem(copyMarkdownItem)
statusMenu.addItem(NSMenuItem.separator())
statusMenu.addItem(quitItem)

func popUp(statusItem: NSStatusItem, menu: NSMenu, _ sender: AnyObject) {
    statusItem.menu = menu
    statusItem.button?.performClick(sender)
    statusItem.menu = nil
}

// from https://stackoverflow.com/a/40040472/5829298
extension String {
    func matchingStrings(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map {
                result.range(at: $0).location != NSNotFound
                    ? nsString.substring(with: result.range(at: $0))
                    : ""
            }
        }
    }
}

func gifIdentifier(url: URL?) -> String? {
    return url?.absoluteString.matchingStrings(regex: "^https://giphy.com/gifs/(.*-)?([^-\n]+)$").first?[2]
}

func gifURL(url: URL?) -> String? {
    if let identifier = gifIdentifier(url: url) {
        return "https://media.giphy.com/media/" + identifier + "/giphy.gif"
    }
    return nil
}

class StatusItemController: NSObject, WKNavigationDelegate {
    @objc func statusItemClicked(_ sender: AnyObject) {
        if (NSApplication.shared.isActive) {
            popUp(statusItem: statusItem, menu: statusMenu, sender)
        } else {
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }
    
    @objc func didBecomeActive(_ sender: AnyObject) {
        popUp(statusItem: statusItem, menu: statusMenu, sender)
    }

    @objc func validateMenuItem(_ sender: AnyObject) -> Bool {
        if let menuItem = sender as? NSMenuItem {
            if (menuItem.action == #selector(StatusItemController.copyURL(_:)) || sender.action == #selector(StatusItemController.copyMarkdown(_:))) {
                return gifIdentifier(url: theWebView.url) != nil
            }
        }
        return true
    }
    
    @objc func webView(_ webView: WKWebView,
                 didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript(hideTrendingChannelsScript) { (_, _) in }
    }
    
    @objc override func observeValue(forKeyPath keyPath: String?,
                            of object: Any?,
                            change: [NSKeyValueChangeKey : Any]?,
                            context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath {
            if (keyPath == "URL") {
                let enabled = gifIdentifier(url: theWebView.url) != nil
                copyURLItem.isEnabled = enabled
                copyMarkdownItem.isEnabled = enabled
            }
        }
    }

    @objc func copyURL(_ sender: AnyObject) {
        if let url = gifURL(url: theWebView.url) {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(url, forType: .string)
        }
        else {
            NSSound.beep()
        }
    }
    
    @objc func copyMarkdown(_ sender: AnyObject) {
        if let url = gifURL(url: theWebView.url) {
            let markdown = "![](" + url + ")"
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(markdown, forType: .string)
        }
        else {
            NSSound.beep()
        }
    }
    
    @objc func quit(_ sender: AnyObject) {
        // Remove the app from the LoginItems
        // Application('System Events').loginItems.whose({path: $.NSBundle.mainBundle.bundlePath.js}).first.delete()
        SMLoginItemSetEnabled("net.bacongravy.giphy-anywhere-helper" as CFString, false)
        NSApp.terminate(sender)
    }
}

let statusItemController = StatusItemController.init()

statusItem.button?.target = statusItemController
statusItem.button?.action = #selector(StatusItemController.statusItemClicked(_:))
statusItem.button?.highlight(false)

NotificationCenter.default.addObserver(statusItemController, selector: #selector(StatusItemController.didBecomeActive(_:)), name: NSApplication.didBecomeActiveNotification, object: nil)

theWebView.navigationDelegate = statusItemController
theWebView.addObserver(statusItemController, forKeyPath: "URL", options: .new, context: nil)

copyURLItem.target = statusItemController
copyURLItem.action = #selector(StatusItemController.copyURL(_:))

copyMarkdownItem.target = statusItemController
copyMarkdownItem.action = #selector(StatusItemController.copyMarkdown(_:))

quitItem.target = statusItemController
quitItem.action = #selector(StatusItemController.quit(_:))

// Add the app to the LoginItems
// Application('System Events').LoginItem({path: $.NSBundle.mainBundle.bundlePath.js, hidden: false}).make()

SMLoginItemSetEnabled("net.bacongravy.giphy-anywhere-helper" as CFString, true)

NSApp.run()
