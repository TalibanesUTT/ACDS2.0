//
//  OrderTimeLineView.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 15/08/24.
//

import SwiftUI

struct OrderTimeLineView: View {
    @State var id: String
    @State var showCancel: Bool = false
    @ObservedObject var userData = UserData.shared
    @EnvironmentObject var socketService: WebSocketService
    @State var showOverlay:Bool = false
    @State var statuses :[Status] = [
        Status(title: "Recibido" , isCompleted: true),
        Status(title: "En revisión", isCompleted: true),
        Status(title: "Emitido", isCompleted: true),
        Status(title: "Aprobado", isCompleted: true),
        Status(title: "En proceso", isCompleted: true),
        Status(title: "En chequeo", isCompleted: true),
        Status(title: "Completado", isCompleted: true),
        Status(title: "Listo para recoger", isCompleted: true),
        Status(title: "Entregado", isCompleted: true),
        Status(title: "Finalizado", isCompleted: true),
    ]
    
    var body: some View {
        ScrollView{
            if (!socketService.sharedStatuses[3].isCompleted && socketService.sharedStatuses[2].isCompleted){
                HStack{
                    Button(action: {acceptOrderRequest()}, label: {
                        Text("Aceptar")
                            .padding()
                            .background(.green)
                            .foregroundStyle(.white)
                            .bold()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    })
                    
                    Button(action: {rejectOrderRequest()}, label: {
                        Text("Rechazar")
                            .padding()
                            .background(.redBtn)
                            .foregroundStyle(.white)
                            .bold()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    })
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
            }
            VStack{
                ForEach(socketService.sharedStatuses.indices, id: \.self){ item in
                    HStack{
                        Text(socketService.sharedStatuses[item].date ?? "------------")
                            .font(.callout)
                        
                        Image(systemName: socketService.sharedStatuses[item].isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(.redBtn)
                        VStack{
                            Text(socketService.sharedStatuses[item].title)
                                .animation(.none, value: socketService.sharedStatuses[item].isCompleted)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.title3)
                            Text("").font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        .padding(.top, 15)
                        Spacer()
                        Text(socketService.sharedStatuses[item].time ?? "No definido").font(.callout)
                            .foregroundStyle(.gray)
                        
                    }
                    .font(.title2)
                    .overlay(alignment: .topLeading){
                        Rectangle()
                            .frame(width: 1, height: socketService.sharedStatuses[item].isCompleted ? 78 : 0)
                            .offset(x:103, y:38)
                            .padding(.leading, 12)
                            .foregroundStyle(.redBtn)
                    }
                    .frame(height: 90)
                }
            }
            .padding()
        }
        .onAppear(perform: {
            getHistoryRequest()
        })
        .alert(isPresented: $showCancel) {
            Alert(title: Text("Advertencia"),
                  message: Text("Estás a punto de rechazar tu órden de servicio, ¿Estás seguro?"),
                  primaryButton: .default(Text("Cancelar")),
                  secondaryButton: .destructive(Text("Confirmar"), action: {
                
            }))
        }
        .overlay(content: {
            if (socketService.showOverlay){
                Rectangle()
                    .foregroundStyle(.gray.opacity(0.8))
                Text(socketService.stTitle)
                    .padding()
                    .foregroundStyle(.white)
                    .bold()
                    .background(.redBtn)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        })
    }
    
    
    func getHistoryRequest(){
        let url = URL(string: "\(userData.prodUrl)/service-orders/status/\(id)")!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"
        request.addValue("Bearer " + userData.token, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error en el request: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    do {
                        let JSONResponse = try JSONSerialization.jsonObject(with:data!) as! [String:Any]
                        let history = JSONResponse["data"] as! [[String:Any]]
                        let lastUpdate = history[0]["status"] as! String
                        print(lastUpdate)
                        DispatchQueue.main.async {
                            
                            if (lastUpdate == "En espera" || lastUpdate == "Cancelado" || lastUpdate == "Rechazado por el cliente"){
                                socketService.showOverlay = true
                                socketService.stTitle = lastUpdate
                            }
                            
                            history.forEach { dict in
                                let title = dict["status"] as! String
                                let datestring = dict["time"] as! String
                                let date = formatDate(datestring)
                                let time = formatHour(datestring)
                                
                                if let element = socketService.sharedStatuses.firstIndex(where: {$0.title == title }){
                                    
                                    socketService.sharedStatuses[element].title = title
                                    socketService.sharedStatuses[element].date = date
                                    socketService.sharedStatuses[element].time = time
                                    
                                }
                            }
                            
                            
                            if let index = socketService.sharedStatuses.firstIndex(where: {$0.title == lastUpdate}){
                                
                                for i in (0...index).reversed() {
                                    socketService.sharedStatuses[i].isCompleted = true
                                }
                            }
                        }
                    }
                    catch{
                        print(error)
                    }
                }
                else {
                    do {
                        let JSONResponse = try JSONSerialization.jsonObject(with:data!) as! [String:Any]
                        print(JSONResponse)
                        let error = JSONResponse["error"] as! [String:Any]
                        let message = error["message"] as! String
                        DispatchQueue.main.async {
                            print(message)
                        }
                    }
                    catch{
                        
                    }
                }
            }
        }
        task.resume()
    }
    
    func acceptOrderRequest(){
        let url = URL(string: "\(userData.prodUrl)/service-orders/updateStatus/\(id)")!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.addValue("Bearer " + userData.token, forHTTPHeaderField: "Authorization")
        
        
        let requestBody: [String: Any] = [
          "rollback": false ,
          "onHold" : false,
          "cancel": false,
          "reject": false
        ]

        do {
          let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
          request.httpBody = jsonData
          request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
          print("Error al convertir el cuerpo del request a JSON: \(error)")
          return
        }
                
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error en el request: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    do {
                        let JSONResponse = try JSONSerialization.jsonObject(with:data!) as! [String:Any]
                       
                        DispatchQueue.main.async {
                        
                        }
                    }
                    catch{
                        print(error)
                    }
                }
                else {
                    do {
                        let JSONResponse = try JSONSerialization.jsonObject(with:data!) as! [String:Any]
                        print(JSONResponse)
                        let error = JSONResponse["error"] as! [String:Any]
                        let message = error["message"] as! String
                        DispatchQueue.main.async {
                            print(message)
                        }
                    }
                    catch{
                        
                    }
                }
            }
        }
        task.resume()
    }
    
    func rejectOrderRequest(){
        let url = URL(string: "\(userData.prodUrl)/service-orders/updateStatus/\(id)")!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.addValue("Bearer " + userData.token, forHTTPHeaderField: "Authorization")
        
        
        let requestBody: [String: Any] = [
          "rollback": false ,
          "onHold" : false,
          "cancel": false,
          "reject": true
        ]

        do {
          let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
          request.httpBody = jsonData
          request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
          print("Error al convertir el cuerpo del request a JSON: \(error)")
          return
        }
                
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error en el request: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    do {
                        let JSONResponse = try JSONSerialization.jsonObject(with:data!) as! [String:Any]
                       
                        DispatchQueue.main.async {
                        
                        }
                    }
                    catch{
                        print(error)
                    }
                }
                else {
                    do {
                        let JSONResponse = try JSONSerialization.jsonObject(with:data!) as! [String:Any]
                        print(JSONResponse)
                        let error = JSONResponse["error"] as! [String:Any]
                        let message = error["message"] as! String
                        DispatchQueue.main.async {
                            print(message)
                        }
                    }
                    catch{
                        
                    }
                }
            }
        }
        task.resume()
    }
    
    
    
    func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        inputFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        var formattedDate = ""
        // Convertimos la cadena a Date
        if let date = inputFormatter.date(from: dateString) {
            // Formateador para la fecha en DD/MM/YYYY
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            formattedDate = dateFormatter.string(from: date)
        
            print("Fecha: \(formattedDate)") // Salida: Fecha: 19/08/2024
        }
        return formattedDate
    }
    
    func formatHour(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        inputFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        var formattedTime = ""
        // Convertimos la cadena a Date
        if let date = inputFormatter.date(from: dateString) {
            // Formateador para la hora en formato de 24 horas
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            timeFormatter.locale = Locale(identifier: "en_GB")
            formattedTime = timeFormatter.string(from: date)
            
            print("Hora: \(formattedTime)")  // Salida: Hora: 00:39
        }
        return formattedTime
    }
}

#Preview {
    OrderTimeLineView(id: "1")
}

struct Status: Identifiable {
    var id = UUID()
    var title: String
    var date: String?
    var time: String?
    var comments: String?
    var isCompleted: Bool
    
}
