import WatchConnectivity

class WatchConnector: NSObject, WCSessionDelegate {
    static let shared = WatchConnector()
    
    private override init() {
        super.init()
    }
    
    func startSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Maneja mensajes entrantes aquí
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        // Maneja contextos de la aplicación entrantes aquí
    }
    
    func sendToken(_ token: String) {
        print("intento")
        if WCSession.default.isReachable {
            print("mandar")
            print(token)
            WCSession.default.sendMessage(["token": token], replyHandler: nil) { error in
                    print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
}
