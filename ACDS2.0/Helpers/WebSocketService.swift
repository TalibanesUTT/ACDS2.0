//
//  WebSocketService.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 16/08/24.
//

import Foundation
import Combine
import SocketIO

class WebSocketService: ObservableObject {
    private var manager = SocketManager(socketURL: URL(string: "https://api.appdevweb.online")!, config: [.log(true), .compress])
    @Published var showOverlay: Bool = false
    @Published var stTitle: String = ""
    @Published var sharedStatuses: [Status] = [
        Status(title: "Recibido" , isCompleted: false),
        Status(title: "En revisión", isCompleted: false),
        Status(title: "Emitido", isCompleted: false),
        Status(title: "Aprobado", isCompleted: false),
        Status(title: "En proceso", isCompleted: false),
        Status(title: "En chequeo", isCompleted: false),
        Status(title: "Completado", isCompleted: false),
        Status(title: "Listo para recoger", isCompleted: false),
        Status(title: "Entregado", isCompleted: false),
        Status(title: "Finalizado", isCompleted: false),
    ]
    
    init(){
        let socket = manager.defaultSocket
        socket.on(clientEvent: .connect){ (data, ack) in
            print("connected")
        }
        
        socket.on("statusNotification"){ (data, ack) in
            let statuses = data as! [[String:Any]]
            let status = statuses[0]
            self.updateStatus(status)
            NotificationManager.shared.scheduleLocalNotification()
        }
        
        socket.connect()
    }
    
    func updateStatus(_ newValue: [String:Any]){
        let title = newValue["status"] as! String
        let date = newValue["date"] as? String
        let time = newValue["time"] as? String
        let rollback = newValue["rollback"] as? Bool ?? false
        
        if (title == "En espera" || title == "Cancelado" || title == "Rechazado por el cliente"){
            print("Se detiene")
            showOverlay = true
            stTitle = title
        }
        else{
            showOverlay = false
        }
        
        if let index = sharedStatuses.firstIndex(where: {$0.title == title}){
            
            if (rollback){
                sharedStatuses[index+1].isCompleted = false
            }
            else {
                sharedStatuses[index].isCompleted = true
                sharedStatuses[index].date = date
                sharedStatuses[index].time = time
            }
            
            for i in (0...index).reversed() {
                sharedStatuses[i].isCompleted = true
            }
            
        }
    }
   
}
