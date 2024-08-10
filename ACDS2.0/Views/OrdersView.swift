//
//  OrdersView.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 09/08/24.
//

import SwiftUI

struct OrdersView: View {
    @ObservedObject var userData = UserData.shared
    @State var carServices:[CarDetail] = [CarDetail(id: "1", fileNumber: "2", initialMileage: 10000, notes: "Sin detalles extras encontrados", createDate: "2024-08-09T06:41:03.000Z", vehicle: ["id": "2", "serialNumber": "09120912938","year": 2023, "color": "Negro", "plates": "FPS-123-503", "owner": "Luis Zapata", "model": ["id": "4", "model": "Lobo", "brand": "Ford"]], appointments: nil, services: [["id": "1", "name": "Afinación"], ["id": "2", "name": "Aceite"]], detail: ["budget": 25000, "totalCost": 50000, "departureDate" : "2024-08-09T06:41:03.000Z", "repairDays": 5, "finalMileage": 12000, "observations": "Todo correcto"], history: nil, actualStatus: "Pendiente")]
    
    @State var alertMessage: String = ""
    @State var showAlert: Bool = false
    @State var customers: [Customer] = [Customer(id: "0", name: "Todos", lastName: "", email: "customer@gmail.com", phoneNumber: "", role: "", active: true)]
    @State private var selectedCustomer: String = "Todos"
    
    var body: some View {
       
        
        ScrollView{
            
            Text("Órdenes de servicio")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            HStack{
                Text("Cliente: ")
                Menu(selectedCustomer) {
                    ForEach(customers, id: \.id) { customer in
                        Button(action: {
                            selectedCustomer = customer.name
                            if (selectedCustomer == "Todos"){
                                pendingServicesRequest()
                            } else {
                                customerServices(customer.id)
                            }
                        }, label: {
                            Text("\(customer.name) \(customer.lastName)")
                        })
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading)
            Divider()
            
            
            LazyVStack{
                ForEach(carServices){ service in
                    NavigationLink(destination: ServiceOrderDetailView(carDetail: service), label: {
                        ZStack{
                            Color(Color.gray.opacity(0.1))
                            VStack{
                                HStack{
                                    Text("\(service.actualStatus ?? "Sin estatus")")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.headline)
                                        .bold()
                                        .padding(.leading, 5)
                                        .lineLimit(1)
                                    Text("\(toDateFromString(service.createDate)!)")
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .font(.footnote)
                                        .padding(.trailing, 5)
                                }
                                Text("Servicio: \(formatServicesInList(service.services))")
                                    .lineLimit(2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.footnote)
                                    .padding(.horizontal, 5)
                                Text("Cliente: \(service.vehicle["owner"]!)")
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 5)
                                    .background(.redBtn)
                                    .foregroundStyle(.white)
                            }
                            .padding(.top,5)
                        }
                        .cornerRadius(8)
                    })
                }
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }.onAppear(perform: {
                selectedCustomer = "Todos"
                pendingServicesRequest()
                customersRequest()
            })
        }
    }
    
    //MARK: - Helpers
    
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
    
    //MARK: - Requests
    
    func pendingServicesRequest(){
        let url = URL(string: "http://localhost:3000/service-orders/status/pending")!
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
                                    detail: dict["detail"] as! [String:Any],
                                    history: dict["history"] as? [String:Any],
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
    
    func customersRequest(){
        let url = URL(string: "http://localhost:3000/customers")!
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
                        let customersData = JSONResponse["data"] as! [[String:Any]]
                        customers = [Customer(id: "0", name: "Todos", lastName: "", email: "customer@gmail.com", phoneNumber: "", role: "", active: true)]
                        
                        customersData.map { dict in
                            let customer = Customer(id: dict["id"] as! String, name: dict["name"] as! String, lastName: dict["lastName"] as! String, email: dict["email"] as! String, phoneNumber: dict["phoneNumber"] as! String, role: dict["role"] as! String, active: (dict["active"] != nil))
                            
                            customers.append(customer)
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
    
    func customerServices(_ userId: String){
        let url = URL(string: "http://localhost:3000/service-orders/user/\(userId)")!
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
                                    detail: dict["detail"] as! [String:Any],
                                    history: dict["history"] as? [String:Any],
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
                            carServices = []
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


struct ServiceOrderDetailView: View {
    var carDetail: CarDetail
    var body: some View {
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
                Text("Presupuesto")
                    .bold()
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(formatStringToCurrency(carDetail.detail["budget"] as! String)!)").font(.callout)
            }
            Spacer()
            
        }
        .padding()
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
    OrdersView()
}
