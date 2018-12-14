import Cocoa
import WebKit

let GIPHY_BASE_URL = "https://giphy.com/"
let GIPHY_TRENDING_GIFS_URL = "https://giphy.com/trending-gifs/"
let GIPHY_FAVICON_URL = "https://giphy.com/favicon.ico"

let GIPHY_GIF_IDENTIFIER_REGEX = "^https://giphy.com/gifs/(.*-)?([^-\n]+)$"

let GIPHY_GIF_URL_PREFIX = "https://media.giphy.com/media/"
let GIPHY_GIF_URL_SUFFIX = "/giphy.gif"

let MARKDOWN_PREFIX = "![]("
let MARKDOWN_SUFFIX = ")"

let IPHONE_USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1"

let STATUS_ITEM_TITLE = "GIPHY Anywhere"
let COPY_URL_MENU_ITEM_TITLE = "Copy GIF URL"
let COPY_MARKDOWN_MENU_ITEM_TITLE = "Copy GIF URL (GitHub Markdown)"
let QUIT_MENU_ITEM_TITLE = "Quit"

let URL_KEY_PATH = "URL"

func gifIdentifier(url: URL?) -> String? {
    return url?.absoluteString.matchingStrings(regex: GIPHY_GIF_IDENTIFIER_REGEX).first?[2]
}

func gifURL(url: URL?) -> String? {
    guard let identifier = gifIdentifier(url: url) else { return nil }
    return GIPHY_GIF_URL_PREFIX + identifier + GIPHY_GIF_URL_SUFFIX
}

func gifMarkdown(url: URL?) -> String? {
    guard let url = gifURL(url: url) else { return nil }
    return MARKDOWN_PREFIX + url + MARKDOWN_SUFFIX
}

func getGiphyImage() -> NSImage {
    return NSImage.init(byReferencing: URL.init(string: GIPHY_FAVICON_URL)!)
}

func getiPhoneWebView() -> WKWebView {
    let webViewRect = NSMakeRect(0, 0, 360, 640)
    let webViewConf = WKWebViewConfiguration.init()
    webViewConf.preferences.plugInsEnabled = true
    let webView = WKWebView.init(frame: webViewRect, configuration: webViewConf)
    webView.customUserAgent = IPHONE_USER_AGENT
    return webView
}

func setPasteboard(string: String?) {
    guard let string = string else { NSSound.beep(); return }
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(string, forType: .string)
}

class MainController: NSObject, NSApplicationDelegate, WKNavigationDelegate {
    
    class func run() {
        let app = NSApplication.shared
        let mainController = MainController.init()
        app.delegate = mainController
        app.run()
    }
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let statusMenu = NSMenu.init()
    let url = URL.init(string: GIPHY_TRENDING_GIFS_URL)!
    let webView = getiPhoneWebView()
    let webViewItem = NSMenuItem.init()
    let copyURLItem = NSMenuItem.init()
    let copyMarkdownItem = NSMenuItem.init()
    let quitItem = NSMenuItem.init()
    
    override init() {
        super.init()
        setLoginItem(enabled: true)
        setupStatusItem()
        setupStatusMenu()
        setupWebView()
    }
    
    func setupStatusItem() {
        let giphyImage = getGiphyImage()
        giphyImage.isValid ?
            (statusItem.button?.image = giphyImage) :
            (statusItem.button?.title = STATUS_ITEM_TITLE)
        statusItem.button?.target = self
        statusItem.button?.action = #selector(MainController.statusItemClicked(_:))
        statusItem.button?.highlight(false)
    }
    
    func setupStatusMenu() {
        webViewItem.view = webView
        copyURLItem.title = COPY_URL_MENU_ITEM_TITLE
        copyURLItem.target = self
        copyURLItem.action = #selector(MainController.copyURL(_:))
        copyMarkdownItem.title = COPY_MARKDOWN_MENU_ITEM_TITLE
        copyMarkdownItem.target = self
        copyMarkdownItem.action = #selector(MainController.copyMarkdown(_:))
        quitItem.title = QUIT_MENU_ITEM_TITLE
        quitItem.target = self
        quitItem.action = #selector(MainController.quit(_:))
        statusMenu.addItem(webViewItem)
        statusMenu.addItem(NSMenuItem.separator())
        statusMenu.addItem(copyURLItem)
        statusMenu.addItem(copyMarkdownItem)
        statusMenu.addItem(NSMenuItem.separator())
        statusMenu.addItem(quitItem)
    }
    
    func setupWebView() {
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: URL_KEY_PATH, options: .new, context: nil)
        reloadWebView()
    }
    
    func reloadWebView() {
        webView.load(URLRequest.init(url: url))
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
    
    func popUpStatusItem() {
        statusItem.menu = statusMenu
        statusItem.button?.performClick(self)
        statusItem.menu = nil
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        popUpStatusItem()
    }
    
    @objc func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
        case #selector(MainController.copyURL(_:)),
             #selector(MainController.copyMarkdown(_:)):
            return gifIdentifier(url: webView.url) != nil
        default:
            return true
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case URL_KEY_PATH:
            switch webView.url?.absoluteString {
            case GIPHY_BASE_URL:
                reloadWebView()
            default:
                let enabled = gifIdentifier(url: webView.url) != nil
                copyURLItem.isEnabled = enabled
                copyMarkdownItem.isEnabled = enabled
            }
            hideUseOurAppButton()
        default: break
        }
    }
    
    @objc func webView(_ webView: WKWebView,
                       didFinish navigation: WKNavigation!) {
        hideUseOurAppButton()
    }
    
    @objc func statusItemClicked(_ sender: AnyObject) {
        NSApp.isActive ?
            popUpStatusItem() : NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func copyURL(_ sender: AnyObject) {
        setPasteboard(string: gifURL(url: webView.url))
    }
    
    @objc func copyMarkdown(_ sender: AnyObject) {
        setPasteboard(string: gifMarkdown(url: webView.url))
    }
    
    @objc func quit(_ sender: AnyObject) {
        setLoginItem(enabled: false)
        NSApp.terminate(sender)
    }
    
}
