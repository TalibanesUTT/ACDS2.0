//
//  WatchConnector.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 12/08/24.
//

import WatchConnectivity

class WatchToiOSConnector: NSObject, ObservableObject, WCSessionDelegate {
    
    var wcSession: WCSession
    @Published var message = ""
    @Published var id = ""
    
    init(wcSession : WCSession = .default){
        self.wcSession = wcSession
        super.init()
        self.wcSession.delegate = self
        wcSession.activate()
        
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.message = message["message"] as? String ?? "not received"
            print(self.message)
            if let id = message["id"] as? NSNumber {
                let stringValue = String(describing: id)
                self.id = stringValue
            }
            print(self.id)
            UserDefaults.standard.set(self.message, forKey: "message")
            UserDefaults.standard.set(self.id, forKey: "id")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
}

