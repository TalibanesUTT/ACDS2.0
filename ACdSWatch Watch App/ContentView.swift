//
//  ContentView.swift
//  ACdSWatch Watch App
//
//  Created by Luis Angel Zapata Zuñiga on 12/08/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var connection = WatchToiOSConnector()
    @State var userData = UserData.shared
    @State var userId = ""
    @State var myCars:[Car] = []
    @State var alertMessage = ""
    @State var showAlert = false
    
    
    @State var token : String? = nil
    var body: some View {
        VStack {
            ScrollView{
                HStack{
                    Text("Mis vehiculos: ")
                        .padding().font(.footnote)
                    Button(action: {vehiclesRequest()}) {
                    Text("Cargar")
                    }
                }
                .padding(.bottom,20)
        
                ForEach(myCars){ car in
                    VStack{
                        HStack{
                            Text("\(car.model["brand"]!)")
                            Text("\(car.model["model"]!)")
                        }
                        Text(String(car.year))
                        Image("generic").resizable()
                            .frame(width: 100, height: 80)
                    }
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                }
            }.alert(isPresented: $showAlert){
                
                Alert(
                    title: Text("Aviso"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }

        }
        
    }
    
    func receiveToken(){
        if let receivedMessage = UserDefaults.standard.string(forKey: "message"){
            token = receivedMessage.description
        }
        else{
            token = nil
            
        }
        
        if let id = UserDefaults.standard.string(forKey: "id"){
            userId = id.description
        }
        else{
            userId = "0"
        }
    }
    
    func vehiclesRequest(){
        receiveToken()
        let url = URL(string: "\(userData.prodUrl)/vehicles/owner/\(userId)")!
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
                        let cars = JSONResponse["data"] as! [[String:Any]]
                        
                        myCars = cars.map({ dict in
                            Car(id: dict["id"] as! String,
                                color: dict["color"] as! String,
                                plates: dict["plates"] as! String,
                                model: dict["model"] as! [String:Any],
                                owner: dict["owner"] as! String,
                                year: dict["year"] as! Int,
                                serialNumber: dict["serialNumber"] as? String ?? "Sin numero")
                        })
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

struct Car: Identifiable{
    let id: String
    let color: String
    let plates: String
    var model: [String:Any]
    let owner: String
    let year: Int
    let serialNumber: String
}

#Preview {
    ContentView(myCars: [Car(id: "1", color: "Negro", plates: "owpeopwqe", model: ["model":"Civic", "brand": "Honda"], owner: "Luis", year: 2023, serialNumber: "1")])
}
