import CoreFoundation
import ServiceManagement

func setLoginItem(enabled: Bool) {
    SMLoginItemSetEnabled("net.bacongravy.giphy-anywhere-helper" as CFString, enabled)
}
