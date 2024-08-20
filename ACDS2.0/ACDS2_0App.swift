//
//  ACDS2_0App.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 29/07/24.
//

import SwiftUI
import UserNotifications

@main
struct ACDS2_0App: App {
    @StateObject private var navigationManager = NavigationManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @ObservedObject var manager = WebSocketService()

    
    var body: some Scene {
        WindowGroup {
            LoginView().environmentObject(navigationManager)
                .environmentObject(manager)
                .onAppear {
                    NotificationManager.shared.requestAuthorization()
                }
        }
    }
}

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error al solicitar permisos de notificación: \(error.localizedDescription)")
            } else {
                print("Permisos de notificación concedidos: \(granted)")
            }
        }
    }
    
    func scheduleLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "ACdS"
        content.body = "Tu órden se ha actualizado"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error al enviar notificación: \(error.localizedDescription)")
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Muestra la notificación incluso cuando la app está en primer plano
        completionHandler([.banner, .sound])
    }
}
