import WatchConnectivity

class WatchConnector: NSObject, WCSessionDelegate {
    
    var wcSession: WCSession
    
    init(wcSession: WCSession = .default) {
        self.wcSession = wcSession
        super.init()
        self.wcSession.delegate = self
        wcSession.activate()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
        
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
}
