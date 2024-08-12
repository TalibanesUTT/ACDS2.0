//
//  WatchConnector.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 12/08/24.
//

import WatchKit
import WatchConnectivity

class WatchToiOSConnector: NSObject, WKExtensionDelegate, WCSessionDelegate {
    
    func applicationDidFinishLaunching() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let token = message["token"] as? String {
            print("enviando")
            NotificationCenter.default.post(name: .didReceiveToken, object: token)
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
}

extension Notification.Name {
    static let didReceiveToken = Notification.Name("didReceiveToken")
}

