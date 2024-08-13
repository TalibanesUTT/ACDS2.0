//
//  AppointmentsDetailView.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 10/08/24.
//

import SwiftUI

struct AppointmentsDetailView: View {
    @State var title = "Nueva cita"
    @State var appointmentId: String? = nil
    @State var appointmentHour: String? = nil
    @State var appointmentDate: String? = nil
    @State var reasonText: String = ""
    @State var reasonError: String? = nil
    @State var selectedDate = Date()
    @State var selectedHour = Date()
    @State var showAlert: Bool = false
    @State var notAbleToCreate: Bool = true
    @State private var alertMessage = ""
    @State var titleAlert: String = ""
    @State var invalidDates : [String]? = []
    @ObservedObject var userData = UserData.shared
    @State private var keyboardHeight: CGFloat = 0


    let dateRange: [Date] = {
        let timeZone = TimeZone(identifier: "America/Mexico_City")!
        let now = Date()
        var calendar = Calendar.current
        let futureDate = calendar.date(byAdding: .day, value: 60, to: now)!
        calendar.timeZone = timeZone

        var dates: [Date] = []
        var currentDate = now
        
        while currentDate <= futureDate {
            let weekday = calendar.component(.weekday, from: currentDate)
            if weekday != 1 {
                dates.append(currentDate)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }()
    
    
    
    var timeSlots: [Date] {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date())
            
            let startTime = calendar.date(byAdding: .hour, value: 9, to: startOfDay)!
            
            
            let endTime = calendar.date(byAdding: .hour, value: 18, to: startOfDay)!
            let endTimeWithMinutes = calendar.date(byAdding: .minute, value: 30, to: endTime)!
            
            
            var timeSlots: [Date] = []
            var currentTime = startTime
            
            while currentTime <= endTimeWithMinutes {
                timeSlots.append(currentTime)
                currentTime = calendar.date(byAdding: .minute, value: 30, to: currentTime)!
            }
            
            return timeSlots
        }

    
    var body: some View {
        ZStack{
            Color("BG").ignoresSafeArea()
            VStack{
                Spacer().frame(height: keyboardHeight)
                Text("Razón")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                    .foregroundStyle(.black)
                
                TextField("", text: $reasonText)
                    .onChange(of: reasonText, {
                        reasonError = invalidReason(reasonText)
                        checkForm()
                    })
                    .padding(.all,10)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                    .keyboardType(.default)
                    .foregroundStyle(.black)
                    .padding((reasonError != nil) ? .top : .bottom, (reasonError != nil) ? 0 : 30)
                
                if let errorMessage = reasonError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(.bottom, 30)
                }
                
                Text("Fecha")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                    .foregroundStyle(.black)
                
                DatePicker("", selection: $selectedDate, in: dateRange.first!...dateRange.last!, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .onChange(of: selectedDate, perform: { newDate in
                        let calendar = Calendar.current
                
                        if !dateRange.contains(selectedDate) {
                            selectedDate = dateRange.first(where: { $0 > selectedDate }) ?? dateRange.first!
                        }
                        
                        let selectedTime = calendar.date(bySettingHour: calendar.component(.hour, from: selectedHour), minute: calendar.component(.minute, from: selectedHour), second: 0, of: newDate)!
                        
                        let currentTime = Date()
                        let eveningTime = calendar.date(bySettingHour: 18, minute: 30, second: 0, of: currentTime)!

                        if calendar.isDate(selectedTime, inSameDayAs: currentTime) && selectedTime > eveningTime {
                            if let nextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: selectedTime)),
                               let nextDayAt9AM = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: nextDay) {
                                selectedDate = nextDayAt9AM
                            }
                        }
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        dateFormatter.timeZone = TimeZone(identifier: "America/Mexico_City")
                        let dateString = dateFormatter.string(from: selectedDate)
                        
                        if (invalidDates!.contains(dateString)){
                            print("si")
                            selectedDate = dateRange.first(where: { $0 > selectedDate }) ?? dateRange.first!
                            
                            alertMessage = "Ya tienes una cita para esta fecha"
                            titleAlert = "Aviso"
                            showAlert = true
                            
                        }
                    })
                    .colorScheme(.light)
                
                Text("Hora")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                    .foregroundStyle(.black)
                
                Picker("Selecciona una hora", selection: $selectedHour) {
                   ForEach(timeSlots, id: \.self) { time in
                       Text(time, style: .time)
                           .frame(maxWidth: .infinity, alignment: .leading)
                           .tag(time)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical,5)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Spacer()

                Button(action: {createAppointmentRequest()}, label: {
                    Text("Confirmar cita")
                        .foregroundStyle(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(Color.blue)
                        .bold()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }).disabled(notAbleToCreate)
                
                Spacer()
            }.navigationTitle(title)
                .navigationBarTitleTextColor(.black)
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(titleAlert),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear(perform: {
                subscribeToKeyboardEvents()
                if (appointmentId != nil){
                    title = "Editar cita"
                }
                appointmentDatesRequest()
            })
            .onDisappear(perform: {
                unsubscribeFromKeyboardEvents()
            })
        }
    }
    
    func createAppointmentRequest(){
        let url = URL(string: "\(userData.prodUrl)/appointments")!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "America/Mexico_City")
        let dateString = dateFormatter.string(from: selectedDate)
        
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "America/Mexico_City")
        dateFormatter.locale = Locale(identifier: "en_GB")

        let hourString = dateFormatter.string(from: selectedHour)
        
        
        
        
        let requestBody: [String: Any] = [
            "userId": userData.id,
            "date": dateString,
            "time": hourString,
            "reason" : reasonText
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
                if (httpResponse.statusCode == 201) {
                    do {
                        print("pre")
                        let JSONResponse = try JSONSerialization.jsonObject(with:data!) as! [String:Any]
                        let message = JSONResponse["message"] as! String
                        print("post")
                        DispatchQueue.main.async {
                            titleAlert = "Aviso"
                            alertMessage = message
                            showAlert = true
                        }
                    }
                    catch{
                        titleAlert = "Error"
                        alertMessage = "Algo salió mal!"
                        showAlert = true
                    }
                }
                else {
                    do {
                        let JSONResponse = try JSONSerialization.jsonObject(with:data!) as! [String:Any]
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
    
    func appointmentDatesRequest(){
        let url = URL(string: "\(userData.prodUrl)/appointments/appointmentsDates/\(userData.id)")!
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
                        let appointments = JSONResponse["data"] as! [String]
                        invalidDates = appointments
                        DispatchQueue.main.async {
                           
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
    
    //MARK: - Helpers
    
    func checkForm() {
        if (!reasonText.isEmpty && reasonError == nil) {
            notAbleToCreate = false
        } else {
            notAbleToCreate = true
        }
    }
    
    func invalidReason(_ value: String)->String?{
        if value.count == 0 {
            return "La razón es obligatoria"
        }
        
        return nil
    }
    
    func subscribeToKeyboardEvents() {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    withAnimation {
                        self.keyboardHeight = keyboardFrame.height - 20
                    }
                }
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                withAnimation {
                    self.keyboardHeight = 0
                }
            }
        }

        func unsubscribeFromKeyboardEvents() {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
}

extension View {
    @available(iOS 14, *)
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor ]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor ]
        return self
    }
}

#Preview {
    AppointmentsDetailView()
}

