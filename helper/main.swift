#!/usr/bin/swift

import Foundation
import Cocoa

let runningApps = NSWorkspace.shared.runningApplications

let isRunning = runningApps.contains {
    $0.bundleIdentifier == "net.bacongravy.giphy-anywhere"
}

if !isRunning {
    var path = Bundle.main.bundlePath as NSString
    for _ in 1...4 {
        path = path.deletingLastPathComponent as NSString
    }
    NSWorkspace.shared.launchApplication(path as String)
}
