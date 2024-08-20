//
//  CarDetailView.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 05/08/24.
//

import SwiftUI

struct CarDetailView: View {
    let car: Car
    @State var carServices:[CarDetail] = []
    @ObservedObject var userData = UserData.shared
    @State var alertMessage: String = ""
    @State var showAlert: Bool = false
    @State var selectedView: subViews = .Services
    var body: some View {
            ZStack{
                Color("BG").ignoresSafeArea()
                VStack{
                    ZStack(alignment:.bottomTrailing){
                        VStack{
                            VStack{
                                Text("\(car.model["model"]!) - \(car.year)")
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.black)
                                
                                Image("\(car.model["brand"]!)")
                                    .resizable().scaledToFit()
                                    .aspectRatio(0.8, contentMode: .fit)
                            }
                            .padding(.bottom, 30)
                            VStack{
                                Picker("", selection: $selectedView){
                                    ForEach(subViews.allCases, id: \.self){
                                        Text($0.rawValue)
                                            .foregroundStyle(.black)
                                    }
                                }
                                .preferredColorScheme(.light)
                                .pickerStyle(SegmentedPickerStyle())
                                SegmentView(selectedView: selectedView, carServices: carServices, car: car)
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
                                servicesRequest(car.id)
                            })
                        }
                    }
                }
            }
    }
    
    func servicesRequest(_ carId: String){
        let url = URL(string: "\(userData.prodUrl)/service-orders/vehicle/\(carId)")!
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
                        let carDetail = JSONResponse["data"] as! [[String:Any]]
                        carServices = carDetail.map { dict in
                            CarDetail(id: dict["id"] as! String,
                                    fileNumber: dict["fileNumber"] as! String,
                                    initialMileage: dict["initialMileage"] as! Int,
                                    notes: dict["notes"] as! String,
                                    createDate: dict["createDate"] as! String,
                                    vehicle: dict["vehicle"] as! [String:Any],
                                    appointments: dict["appointment"] as? [String:Any],
                                    services: dict["services"] as! [[String:Any]],
                                      detail: dict["detail"] as? [String:Any] ?? [:],
                                    history: dict["history"] as? [[String:Any]],
                                    actualStatus: dict["actualStatus"] as? String)
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

enum subViews: String, CaseIterable{
    case Services = "Servicios"
    case Detail = "Detalle"
}

struct SegmentView: View {
    var selectedView: subViews
    var carServices: [CarDetail]
    var car: Car
    var body: some View {
        switch selectedView {
            case .Detail:
                DetailView(car: car)
            case .Services:
                ServicesView(carServices: carServices)
        }
        
    }
}

struct ServicesView: View {
    var carServices: [CarDetail]
    var body: some View{
        ZStack{
            Color("BG").ignoresSafeArea()
            ScrollView{
                LazyVStack{
                    ForEach(carServices){ service in
                        NavigationLink(destination: OrderDetailView(carDetail: service), label: {
                            ZStack{
                                Color(Color.gray.opacity(0.1))
                                VStack{
                                    HStack{
                                        Text("\(service.actualStatus ?? "Sin estatus") - \(formatStringToCurrency(service.detail["totalCost"] as? String ?? "0") ?? "0")")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .font(.headline)
                                            .bold()
                                            .padding(.leading, 5)
                                            .lineLimit(1)
                                            .foregroundStyle(.black)
                                        
                                        Text("\(toDateFromString(service.createDate)!)")
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .font(.footnote)
                                            .padding(.trailing, 5)
                                            .foregroundStyle(.black)
                                    }
                                    .padding(.bottom, 2)
                                    Text("Servicio: \(formatServicesInList(service.services))")
                                        .lineLimit(2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.footnote)
                                        .padding(.horizontal, 5)
                                        .foregroundStyle(.black)
                                }
                                .padding(.vertical, 8)
                            }
                            .cornerRadius(8)
                        })
                    }
                }
            }
        }
    }
    
    func toDateFromString(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        if let date = dateFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.locale = Locale(identifier: "es_ES")
            outputFormatter.dateFormat = "dd MMMM yyyy, HH:mm"

            return outputFormatter.string(from: date)
        } else {
            print("Error: No se pudo convertir la cadena \(dateString) a una fecha.")
            return nil
        }
    }
    
    func formatStringToCurrency(_ amountString: String) -> String? {
        
        guard let amount = Double(amountString) else {
            print("Error: No se pudo convertir la cadena \(amountString) a un número.")
            return nil
        }

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "es_MX")

        if let formattedAmount = numberFormatter.string(from: NSNumber(value: amount)) {
            return formattedAmount
        } else {
            print("Error: No se pudo formatear el número \(amount) a una cadena de moneda.")
            return nil
        }
    }
    
    func formatServicesInList(_ services: [[String:Any]]) -> String {
        return services
                .compactMap { $0["name"] as? String }
                .joined(separator: ", ")
    }

}

struct DetailView: View {
    var car: Car
    var body: some View {
        ZStack{
            Color("BG").ignoresSafeArea()
            VStack{
                HStack{
                    Text("Modelo")
                        .bold()
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(car.model["model"]!)").font(.title3)
                }
                Divider()
                HStack{
                    Text("Marca")
                        .bold()
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(car.model["brand"]!)").font(.title3)
                }
                Divider()
                HStack{
                    Text("Año")
                        .bold()
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(String(car.year))").font(.title3)
                }
                Divider()
                HStack{
                    Text("Placas")
                        .bold()
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(car.plates)").font(.title3)
                }
                Divider()
                HStack{
                    Text("Numero de serie")
                        .bold()
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(car.serialNumber)").font(.title2)
                }
                Divider()
                HStack{
                    Text("Color")
                        .bold()
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(car.color)").font(.title2)
                }
                
            }
            .foregroundStyle(.black)
            .padding(.bottom, 60)
        }
    }
}

struct OrderDetailView: View {
    var carDetail: CarDetail
    var body: some View {
        
        ZStack{
            Color("BG").ignoresSafeArea()
            ZStack(alignment: .bottomTrailing){
                VStack{
                    HStack{
                        Text("Fecha de servicio")
                            .bold()
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(toDateFromString(carDetail.createDate)!)")
                            .font(.callout)
                    }
                    Divider()
                    HStack{
                        Text("Estatus")
                            .bold()
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(carDetail.actualStatus ?? "Sin estatus")")
                            .font(.callout)
                    }
                    Divider()
                    HStack{
                        Text("Notas iniciales")
                            .bold()
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(carDetail.notes)")
                            .font(.callout)
                    }
                    Divider()
                    HStack{
                        Text("Kilometraje inicial")
                            .bold()
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(carDetail.initialMileage) km")
                            .font(.callout)
                    }
                    Divider()
                    HStack{
                        Text("Servicios")
                            .bold()
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(formatServicesInList(carDetail.services))")
                            .font(.callout)
                    }
                    Divider()
                    HStack{
                        Text("Color")
                            .bold()
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(carDetail.vehicle["color"]!)")
                            .font(.callout)
                    }
                    Divider()
                    HStack{
                        Text("Presupuesto")
                            .bold()
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(formatStringToCurrency(carDetail.detail["budget"] as? String ?? "0")!)").font(.callout)
                    }
                    Divider()
                    HStack{
                        Text("Costo total")
                            .bold()
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(formatStringToCurrency(carDetail.detail["totalCost"] as? String ?? "0")!)")
                            .font(.callout)
                    }
                    Divider()
                    HStack{
                        Text("Fecha de salida")
                            .bold()
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(toDateFromString(carDetail.detail["departureDate"] as? String ?? "Fecha no disponible") ?? "Fecha no disponible")")
                            .font(.callout)
                    }
                    Divider()
                    HStack{
                        Text("Días en reparacion")
                            .bold()
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(carDetail.detail["repairDays"] as? String ?? "No disponibles")")
                        
                            .font(.callout)
                    }
                    Divider()
                    HStack{
                        Text("Kilometraje final")
                            .bold()
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(carDetail.detail["finalMileage"] as? String ?? "No disponible") km")
                            .font(.callout)
                    }
                    Divider()
                    HStack{
                        Text("Observaciones")
                            .bold()
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(carDetail.detail["observations"] as? String ?? "Sin observaciones")")
                            .font(.callout)
                    }
                    
                    Spacer()
                    
                }
                
                NavigationLink(destination: OrderTimeLineView(id: carDetail.id), label: {
                    Text("Estado actual")
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                        .foregroundStyle(.white)
                        .bold()
                        .background(.redBtn)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: .gray, radius: 5, x: 0, y: 5)
                })
                .padding()
            }
            .padding()
            .foregroundStyle(.black)
        }
    }

    func formatServicesInList(_ services: [[String:Any]]) -> String {
         return services
                 .compactMap { $0["name"] as? String }
                 .joined(separator: ", ")
    }
    
    func toDateFromString(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        if let date = dateFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.locale = Locale(identifier: "es_ES")
            outputFormatter.dateFormat = "dd MMMM yyyy, HH:mm"

            return outputFormatter.string(from: date)
        } else {
            print("Error: No se pudo convertir la cadena \(dateString) a una fecha.")
            return nil
        }
    }
    
    func formatIntegerToCurrency(_ amount: Int) -> String? {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "es_MX")
        
        if let formattedAmount = numberFormatter.string(from: NSNumber(value: amount)) {
            return formattedAmount
        } else {
            print("Error: No se pudo formatear el número \(amount) a una cadena de moneda.")
            return nil
        }
    }
    
    func formatStringToCurrency(_ amountString: String) -> String? {
        
        guard let amount = Double(amountString) else {
            print("Error: No se pudo convertir la cadena \(amountString) a un número.")
            return nil
        }

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "es_MX")

        if let formattedAmount = numberFormatter.string(from: NSNumber(value: amount)) {
            return formattedAmount
        } else {
            print("Error: No se pudo formatear el número \(amount) a una cadena de moneda.")
            return nil
        }
    }
                    
}


#Preview {
    //CarDetailView(car: Car(id: "1", color: "", plates: "90239i320", model: ["model": "Lobo", "brand": "Ford"], owner: "Luis", year: 2023, serialNumber: "ekkd"))
    OrderDetailView(carDetail: CarDetail(id: "1", fileNumber: "2", initialMileage: 10000, notes: "Sin detalles extras encontrados", createDate: "2024-08-10T10:52:02.000Z", vehicle: ["id": "2", "serialNumber": "09120912938","year": 2023, "color": "Negro", "plates": "FPS-123-503", "owner": "Luis Zapata", "model": ["id": "4", "model": "Lobo", "brand": "Ford"]], appointments: nil, services: [["id": "1", "name": "Afinación"], ["id": "2", "name": "Aceite"]], detail: ["budget": 25000, "totalCost": 50000, "departureDate" : "2024-08-10T10:52:02.000Z", "repairDays": 5, "finalMileage": 12000, "observations": "Todo correcto"], history: nil, actualStatus: "Pendiente"))
}
