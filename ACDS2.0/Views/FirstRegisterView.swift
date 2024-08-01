//
//  FirstRegisterView.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 31/07/24.
//

import SwiftUI

struct FirstRegisterView: View {
    @State var nameText: String = ""
    @State var lastNameText: String = ""
    @State var emailText: String = ""
    @State var showAlert: Bool = false
    @State var alertMessage: String = ""
    @State var emailError: String? = nil
    @State var nameError: String? = nil
    @State var lastNameError: String?  = nil
    @State var notAbleToContinue: Bool = true
    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject var userData = UserData.shared
    
    var body: some View{
        ZStack{
            Color("BG").ignoresSafeArea()
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                
                Text("Nombre")
                    .bold()
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.black)
                
                TextField("", text: limitedTextBinding($nameText, maxLength: 60),
                        onEditingChanged:{ _ in nameError = invalidName(nameText)
                        checkForm()
                    })
                    .padding(.all,10)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                    .padding((nameError != nil) ? .top: .bottom, (nameError != nil) ? 0 : 30)
                    .keyboardType(.default)
                    .foregroundStyle(.black)
                
                if let errorMessage = nameError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(.bottom, 30)
                }
                
                Text("Apellidos")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.black)
                
                TextField("", text: limitedTextBinding($lastNameText, maxLength: 60),
                        onEditingChanged: {_ in lastNameError = invalidLastName(lastNameText)
                        checkForm()
                    })
                .padding(.all, 10)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                    .padding((lastNameError != nil) ? .top: .bottom, (lastNameError != nil) ? 0 : 30)
                    .keyboardType(.default)
                    .foregroundStyle(.black)
                
                if let errorMessage = lastNameError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(.bottom, 30)
                }
                
                Text("Correo electrónico")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.black)
                
                TextField("", text: limitedTextBinding($emailText, maxLength: 100),
                        onEditingChanged: { _ in emailError = invalidEmail(emailText)
                        checkForm()
                    })
                    .padding(.all, 10)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                    .padding((emailError != nil) ? .top: .bottom, (emailError != nil) ? 0 : 30)
                    .keyboardType(.emailAddress)
                    .foregroundStyle(.black)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                
                if let errorMessage = emailError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(.bottom, 30)
                }
                
                Button(action: {verifyExistingEmail()}, label: {
                    Text("Siguiente")
                        .padding(.all, 12)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .background(Color("RedBtn"))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .bold()
                })
                .disabled(notAbleToContinue)
                
                Text("¿Ya tienes una cuenta?")
                    .italic()
                    .opacity(1)
                    .foregroundColor(Color.gray.opacity(0.6))
                    .font(.footnote)
                
                Button(action: {
                    navigationManager.resetToRoot()
                }, label: {
                    Text("Inicia sesion aquí")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundColor(Color("RedBtn"))
                    .underline()
                    .font(.footnote)
                    
                })
                Spacer()
            }.padding(20)
        }.alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
        
    func navigateToSRV(){
        navigationManager.path.append("SecondRegister")
    }
    
    //MARK: - Requests
    
    func verifyExistingEmail(){
        let url = URL(string: "http://localhost:3000/auth/existsUser")!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
                
        let requestBody: [String: Any] = [
            "email": emailText
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
                        let exists = JSONResponse["data"] as! Bool
                        print(JSONResponse)
                        if (exists){
                            DispatchQueue.main.async {
                                alertMessage = "El correo ya está en uso"
                                showAlert = true
                            }
                        }
                        else{
                            DispatchQueue.main.async {
                                self.userData.email = emailText
                                self.userData.name = nameText
                                self.userData.lastName = lastNameText
                                navigateToSRV()
                            }
                        }
                    }
                    catch{
                        print(error)
                        DispatchQueue.main.async {
                            alertMessage = "Algo salió mal!"
                            showAlert = true
                        }
                    }
                }
                else {
                    print(error!)
                    DispatchQueue.main.async {
                        alertMessage = "Algo salió mal!"
                        showAlert  = true
                    }
                }
            }
        }
        task.resume()
    }
    
    //MARK: - Validations
    
    func checkForm() {
        if (nameError == nil && lastNameError == nil && emailError == nil) && (!emailText.isEmpty && !nameText.isEmpty && !lastNameText.isEmpty){
            notAbleToContinue = false
        } else {
            notAbleToContinue = true
        }
    }
    
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
    
    
    func invalidName(_ value: String)-> String? {
            if value.count == 0 {
                return "Este campo es requerido"
            }
            
            let expresionRegular = "^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ\\s]+$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", expresionRegular)

            if !predicate.evaluate(with: value) {
                return "Este campo sólo acepta letras"
            }

            return nil
    }
    
    
    func invalidLastName(_ value: String)-> String? {
        if value.count == 0 {
            return "Este campo es requerido"
        }
        
        let expresionRegular = "^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ\\s]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", expresionRegular)

        if !predicate.evaluate(with: value) {
            return "Este campo sólo acepta letras"
        }

        return nil
    }
    
    func invalidEmail(_ value: String)-> String? {
            if value.count == 0 {
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
    FirstRegisterView()
}
