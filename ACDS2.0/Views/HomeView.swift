//
//  HomeView.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 31/07/24.
//

import SwiftUI

struct HomeView: View {
    let images = ["anounce1", "anounce2", "anounce3"]
    @ObservedObject var userData = UserData.shared
    @EnvironmentObject var navigationManager: NavigationManager
    @State var alertMessage: String = ""
    @State var showAlert: Bool = false
    @State var myCars:[Car] = []
    @State var selectedCar: Car? = Car(id: "9000", color: "Negro", plates: "FPS-12-33", model: ["model": "Civic", "brand":"Honda"], owner: "Luis Zapata", year: 2022, serialNumber: "111111")
    
    var body: some View {
        ZStack{
            Color("BG").ignoresSafeArea()
            ScrollView{
                Text("Avisos recientes")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.black)
                
                TabView{
                    ForEach(images, id: \.self){ imageName in
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .cornerRadius(10)
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 220)
                
                Text("Mis autos")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 40)
                    .foregroundStyle(.black)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(myCars){ car in
                        NavigationLink(destination: CarDetailView(car: (selectedCar)!), label: {
                            VStack{
                                Image("genericcar")
                                    .resizable()
                                    .scaledToFit()
                                Text("\(car.model["model"]!)").bold()
                                Text("\(String(car.year))").bold()
                                
                            }
                            .contentShape(Rectangle())
                        }).onTapGesture {
                            vehicleDetailRequest(car.id)
                        }
                    }
                }
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            
            .onAppear(perform: {
                vehiclesRequest()
            })
        }
    }
        //MARK: - Requests
        
        func vehicleDetailRequest(_ carId: String){
            let url = URL(string: "http://localhost:3000/vehicles/\(carId)")!
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
                            let car = JSONResponse["data"] as! [String:Any]
                            
                            DispatchQueue.main.async {
                                selectedCar = Car(id: car["id"] as! String,
                                color: car["color"] as! String,
                                plates: car["plates"] as! String,
                                model: car["model"] as! [String:Any],
                                owner: car["owner"] as! String,
                                year: car["year"] as! Int,
                                serialNumber: car["serialNumber"] as! String)
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
        
        func vehiclesRequest(){
            let url = URL(string: "http://localhost:3000/vehicles/owner/\(userData.id)")!
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
                                    serialNumber: dict["serialNumber"] as! String)
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


#Preview {
    HomeView()
}
