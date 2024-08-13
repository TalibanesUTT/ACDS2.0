//
//  AppointmentsView.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 10/08/24.
//

import SwiftUI

struct Appointment: Identifiable{
    var id: String
    var date: String
    var time: String
    var reason: String
    var status: String

    
    init?(dict: [String: Any]) {
        guard
            let id = dict["id"] as? String,
            let date = dict["date"] as? String,
            let time = dict["time"] as? String,
            let reason = dict["reason"] as? String,
            let status = dict["status"] as? String
        else {
            return nil
        }

        self.id = id
        self.date = date
        self.time = time
        self.reason = reason
        self.status = status
    }
    
}

struct AppointmentsView: View {
    @ObservedObject var userData = UserData.shared
    @State var titleAlert: String = ""
    @State var alertMessage: String = ""
    @State var showAlert: Bool = false
    @State var appoints: [Appointment] = []
    
    var body: some View {
        ZStack{
            Color("BG").ignoresSafeArea()
            VStack{
                Text("Citas")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.black)
                ZStack(alignment: .bottomTrailing){
                    ScrollView{
                        ForEach(appoints){ app in
                            VStack{
                                HStack{
                                    Text(app.status)
                                        .foregroundStyle(.black)
                                    Text("- \(app.time)")
                                        .foregroundStyle(.black)
                                    Text(app.date)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .foregroundStyle(.black.opacity(0.6))
                                }
                                .font(.caption)
                                .bold()
                                HStack{
                                    Text(app.reason)
                                        .font(.subheadline)
                                        .lineLimit(2)
                                        .foregroundStyle(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    if app.status == "Pendiente" {
                                        Menu {
                                            // NavigationLink(destination: AppointmentsDetailView(
                                            //   title: "Editar cita",
                                            // appointmentId: app.id,
                                            //appointmentHour: app.time,
                                            //appointmentDate: app.date,
                                            //reasonError: nil)) {
                                            //Text("Editar")
                                            Button("Cancelar") {
                                                cancelAppointmentRequest(app.id)
                                                    
                                            }.foregroundStyle(.black)
                                        } label: {
                                            Image(systemName: "ellipsis")
                                                .foregroundStyle(.redBtn)
                                        }
                                    
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                        }
                    }
                    NavigationLink(destination: AppointmentsDetailView(), label: {
                        Image(systemName: "plus")
                            .font(.largeTitle     )
                            .foregroundStyle(.redBtn)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .gray, radius: 5, x: 0, y: 5)

                    })
                    .padding()
                }
            }
            .alert(isPresented: $showAlert){
                Alert(title: Text(titleAlert),
                message: Text(alertMessage),
                      dismissButton: .default(Text("Ok").foregroundStyle(.blue)))
            }
            .padding()
            .onAppear(perform: {
                myAppointmentsRequest()
            })

        }
    }
    
    //MARK: - Requests
    func myAppointmentsRequest(){
        let url = URL(string: "\(userData.prodUrl)/appointments")!
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
                        let appointments = JSONResponse["data"] as! [[String:Any]]
                        DispatchQueue.main.async {
                            appoints = appointments.compactMap { Appointment(dict: $0) }
                        }
                    }
                    catch{
                        alertMessage = "Algo salió mal"
                        showAlert = true
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
                            alertMessage = message
                            showAlert = true
                        }
                    }
                    catch{
                        alertMessage = "Algo salió mal"
                        showAlert = true
                    }
                }
            }
        }
        task.resume()
    }
    
    func cancelAppointmentRequest(_ appointementId: String){
        let url = URL(string: "\(userData.prodUrl)/appointments/cancel/\(appointementId)")!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "PUT"
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
                        let message = JSONResponse["message"] as! String
                        DispatchQueue.main.async {
                            alertMessage = message
                            titleAlert = "Aviso"
                            showAlert = true
                            appoints.removeAll { appointment in
                                appointment.id == appointementId
                            }
                        }
                    }
                    catch{
                        alertMessage = "Algo salió mal"
                        showAlert = true
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
                            alertMessage = message
                            showAlert = true
                        }
                    }
                    catch{
                        alertMessage = "Algo salió mal"
                        showAlert = true
                    }
                }
            }
        }
        task.resume()
    }
    
}
#Preview {
    AppointmentsView()
}
