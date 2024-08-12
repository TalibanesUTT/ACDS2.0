//
//  PassRecoverView.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 01/08/24.
//

import SwiftUI

struct PassRecoverView: View {
    @State var emailText: String = ""
    @State var emailError: String? = nil
    @State var showAlert: Bool = false
    @State private var alertMessage = ""
    @State var titleAlert: String = ""
    @State var notAbleToComplete: Bool = true
    @State var userData = UserData.shared
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        ZStack{
            Color("BG").ignoresSafeArea()
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                
                Text("Correo electrónico")
                    .bold()
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.black)
                
                TextField("", text: $emailText)
                    .onChange(of: emailText, {
                        limitText(&emailText, to: 30)
                        emailError = invalidEmail(emailText)
                        checkForm()
                    })
                    .padding(.all,10)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                    .padding((emailError != nil) ? .top : .bottom, (emailError != nil) ? 0 : 30)
                    .keyboardType(.emailAddress)
                    .foregroundStyle(.black)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    
                
                if let errorMessage = emailError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(.bottom, 30)
                }
                Button(action: { recoverPasswordRequest() }, label: {
                    Text("Recuperar contraseña")
                        .padding(.all, 12)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .background(Color("RedBtn"))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .bold()
                })
                .disabled(notAbleToComplete)
                
                Spacer()
        }.padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(titleAlert),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func navigateToLogin(){
        navigationManager.resetToRoot()
    }
    
    //MARK: - Requests
    
    func recoverPasswordRequest(){
        let url = URL(string: "\(userData.prodUrl)/user-management/recoverPassword")!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        
        
        let requestBody: [String: Any] = [
            "email": emailText,
            "fromAdmin": false
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
                        let message = JSONResponse["message"] as! String
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
    
    //MARK: - Validations
    
    func limitedTextBinding(_ binding: Binding<String>, maxLength: Int) -> Binding<String> {
        checkForm()
            return Binding(
                get: { binding.wrappedValue },
                set: { newValue in
                    if newValue.count <= maxLength {
                        binding.wrappedValue = newValue
                    }
                }
            )
    }
    
    func checkForm(){
        if(emailError == nil && !emailText.isEmpty){
            notAbleToComplete = false
        }
        else {
            notAbleToComplete = true
        }
    }
    
    func invalidEmail(_ value: String) -> String? {
        if value.isEmpty {
            return "Este campo es requerido"
        }
        
        let expresionRegular = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", expresionRegular)
        
        if !predicate.evaluate(with: value) {
            return "Correo electrónico inválido"
        }
        
        return nil
    }
}

#Preview {
    PassRecoverView()
}
