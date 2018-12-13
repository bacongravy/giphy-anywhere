#!/usr/bin/swift

import Cocoa
import WebKit
import ServiceManagement

func setLoginItem(enabled: Bool) {
    SMLoginItemSetEnabled("net.bacongravy.giphy-anywhere-helper" as CFString, enabled)
}

func gifIdentifier(url: URL?) -> String? {
    return url?.absoluteString.matchingStrings(regex: "^https://giphy.com/gifs/(.*-)?([^-\n]+)$").first?[2]
}

func gifURL(url: URL?) -> String? {
    guard let identifier = gifIdentifier(url: url) else { return nil }
    return "https://media.giphy.com/media/" + identifier + "/giphy.gif"
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

func getGiphyImage() -> NSImage {
    return NSImage.init(byReferencing: URL.init(string: "https://giphy.com/favicon.ico")!)
}

func getiPhoneWebView() -> WKWebView {
    let webViewRect = NSMakeRect(0, 0, 360, 640)
    let webViewCustomUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1"
    let webViewConf = WKWebViewConfiguration.init()
    webViewConf.preferences.plugInsEnabled = true
    let webView = WKWebView.init(frame: webViewRect, configuration: webViewConf)
    webView.customUserAgent = webViewCustomUserAgent
    return webView
}

class MainController: NSObject, NSApplicationDelegate {

    class func run() {
        let app = NSApplication.shared
        let mainController = MainController.init()
        app.delegate = mainController
        app.run()
    }
    
    let giphyImage = getGiphyImage()
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let statusMenu = NSMenu.init()
    let url = URL.init(string: "https://giphy.com/trending-gifs")
    let webView = getiPhoneWebView()
    let webViewItem = NSMenuItem.init()
    let copyURLItem = NSMenuItem.init()
    let copyMarkdownItem = NSMenuItem.init()
    let quitItem = NSMenuItem.init()

    override init() {
        super.init()
        
        if (giphyImage.isValid) {
            statusItem.button?.image = giphyImage
        }
        else {
            statusItem.button?.title = "GIPHY Anywhere"
        }
        
        statusItem.button?.target = self
        statusItem.button?.action = #selector(MainController.statusItemClicked(_:))
        statusItem.button?.highlight(false)

        webView.load(URLRequest.init(url: url!))
        
        webViewItem.view = webView
        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)

        copyURLItem.title = "Copy GIF URL"
        copyURLItem.target = self
        copyURLItem.action = #selector(MainController.copyURL(_:))
        
        copyMarkdownItem.title = "Copy GIF URL (GitHub Markdown)"
        copyMarkdownItem.target = self
        copyMarkdownItem.action = #selector(MainController.copyMarkdown(_:))
        
        quitItem.title = "Quit"
        quitItem.target = self
        quitItem.action = #selector(MainController.quit(_:))
        
        statusMenu.addItem(webViewItem)
        statusMenu.addItem(NSMenuItem.separator())
        statusMenu.addItem(copyURLItem)
        statusMenu.addItem(copyMarkdownItem)
        statusMenu.addItem(NSMenuItem.separator())
        statusMenu.addItem(quitItem)

        setLoginItem(enabled: true)
    }
    
    func popUpStatusItem() {
        statusItem.menu = statusMenu
        statusItem.button?.performClick(self)
        statusItem.menu = nil
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        popUpStatusItem()
    }

    @objc func validateMenuItem(_ sender: AnyObject?) -> Bool {
        let menuItem = sender as? NSMenuItem
        switch menuItem?.action {
        case #selector(MainController.copyURL(_:)),
             #selector(MainController.copyMarkdown(_:)):
            return gifIdentifier(url: webView.url) != nil
        default:
            return true
        }
    }
    
    func hideUseOurAppButton() {
        webView.evaluateJavaScript("""
            var aTags = document.getElementsByTagName('a');
            var searchText = 'Use Our App';
            var foundElement;
            for (var i = 0; i < aTags.length; i++) {
                if (aTags[i].textContent == searchText) {
                    foundElement = aTags[i];
                    break;
                }
            }
            if (foundElement) {
                foundElement.style = "display: none;";
            }
            """
        ) { (_, _) in }
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                            of object: Any?,
                            change: [NSKeyValueChangeKey : Any]?,
                            context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "URL":
            switch webView.url?.absoluteString {
            case "https://giphy.com/":
                webView.load(URLRequest.init(url: url!))
            default:
                let enabled = gifIdentifier(url: webView.url) != nil
                copyURLItem.isEnabled = enabled
                copyMarkdownItem.isEnabled = enabled
            }
            hideUseOurAppButton()
        default: break
        }
    }

    @objc func statusItemClicked(_ sender: AnyObject) {
        if (NSApp.isActive) {
            popUpStatusItem()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    @objc func copyURL(_ sender: AnyObject) {
        if let url = gifURL(url: webView.url) {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(url, forType: .string)
        }
        else {
            NSSound.beep()
        }
    }
    
    @objc func copyMarkdown(_ sender: AnyObject) {
        if let url = gifURL(url: webView.url) {
            let markdown = "![](" + url + ")"
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(markdown, forType: .string)
        }
        else {
            NSSound.beep()
        }
    }
    
    @objc func quit(_ sender: AnyObject) {
        setLoginItem(enabled: false)
        NSApp.terminate(sender)
    }
    
}

MainController.run()
