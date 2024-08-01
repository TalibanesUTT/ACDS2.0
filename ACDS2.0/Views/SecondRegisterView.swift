//
//  SecondRegisterView.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 31/07/24.
//

import SwiftUI

struct SecondRegisterView: View {
    @State var passwordText: String = ""
    @State var confirmPasswordText: String = ""
    @State var phoneText: String = ""
    @State var showAlert: Bool = false
    @State var alertMessage: String = ""
    @State var notAbleToRegister: Bool = true
    @State var passwordError: String? = nil
    @State var confirmPasswordError: String? = nil
    @State var phoneError : String? = nil
    @ObservedObject var userData = UserData.shared
    
    @EnvironmentObject var navigationManager: NavigationManager

    
    var body: some View {
        ZStack{
            Color("BG").ignoresSafeArea()
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                
                Text("Contraseña")
                    .bold()
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.black)
                
                SecureField("", text: limitedTextBinding($passwordText, maxLength: 30))
                    .padding(.all,10)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                    .padding((passwordError != nil) ? .top : .bottom, (passwordError != nil) ? 0 : 30)
                    .keyboardType(.default)
                    .onChange(of: passwordText) { newValue in
                            passwordError = invalidPassword(newValue)
                            checkForm()
                        }
                
                if let errorMessage = passwordError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 30)
                }
                
                Text("Confirmar contraseña")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.black)
                
                SecureField("", text: limitedTextBinding($confirmPasswordText, maxLength: 30))
                    .padding(.all, 10)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                    .padding((confirmPasswordError != nil) ? .top : .bottom, (confirmPasswordError != nil) ? 0 : 30)
                    .keyboardType(.default)
                    .onChange(of: confirmPasswordText) { newValue in
                        confirmPasswordError = invalidPasswordConfirmation(newValue)
                        checkForm()
                    }
                
                if let errorMessage = confirmPasswordError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 30)
                }
                
                Text("Número de teléfono")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.black)
                
                TextField("", text: limitedTextBinding($phoneText, maxLength: 10),
                        onEditingChanged: { _ in phoneError = invalidNumber(phoneText)
                        checkForm()
                    })
                    .padding(.all, 10)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                    .padding((phoneError != nil) ? .top : .bottom, (phoneError != nil) ? 0 : 30)
                    .keyboardType(.numberPad)
                
                if let errorMessage = phoneError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 30)
                }
                
                Button(action: {registerRequest()}, label: {
                    Text("Siguiente")
                        .padding(.all, 12)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .background(Color("RedBtn"))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .bold()
                })
                .disabled(notAbleToRegister)
                
                Spacer()
            }.padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func navigateToCodeView(){
        navigationManager.path.append("Code")
    }
    
    //MARK: - Requests
    
    func registerRequest() {
        let url = URL(string: "http://localhost:3000/auth/register")!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        
        let name = userData.name
        let lastName = userData.lastName
        let email = userData.email
        let password = passwordText
        let passwordConfirm = confirmPasswordText
        let phone = phoneText
    
          
       let requestBody: [String: Any] = [
           "name": name,
           "lastName": lastName,
           "phone": phone,
           "email": email,
           "password": password,
           "passwordConfirmation": passwordConfirm
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
                    let JSONResponse = try JSONSerialization.jsonObject(with:data!) as! [String:Any]
                    self.userData.signedRoute = JSONResponse["url"] as! String
                    DispatchQueue.main.async {
                        navigateToCodeView()
                    }
                }
                catch{
                    alertMessage = "Algo salió mal!"
                    showAlert = true
                }
            }
            else {
                do {
                    let JSONResponse = try JSONSerialization.jsonObject(with:data!) as! [String:Any]
                    print(JSONResponse)
                    let error = JSONResponse["error"] as! [String:Any]
                    let message = error["message"] as! String
                    DispatchQueue.main.async {
                        alertMessage = "Algo salió mal!"
                        showAlert = true
                    }
                }
                catch{
                    alertMessage = "Algo salió sal!"
                    showAlert = true
                }
            }
        }
    }
        task.resume()
    }
    
    //MARK: - Validations
    
    func checkForm() {
        if ((!passwordText.isEmpty && !confirmPasswordText.isEmpty && !phoneText.isEmpty) && (passwordError == nil && confirmPasswordError == nil && phoneError == nil))  {
                notAbleToRegister = false
        } else {
                notAbleToRegister = true
        }
    }
    
    func invalidNumber(_ value: String)-> String? {
            if value.count == 0 {
                return "Este campo es requerido"
            }
            
            if value.count < 10 {
                return "Este campo debe tener al menos 10 caracteres"
            }

            return nil
        }
    
    func invalidPassword(_ value: String)-> String? {
            if value.count == 0 {
                return "Este campo es requerido"
            }
            
            if value.count < 8 {
                return  "Este campo debe tener al menos 8 caracteres"
            }
            
            if containsDigit(value) {
                return "Este campo debe contener al menos un dígito"
            }
            
            if containsLowerCase(value) {
                return "Este campo debe contener al menos una minúscula"
            }
            
            if containsUpperCase(value) {
                return "Este campo debe contener al menos una mayúscula"
            }
            
            if containsSpecialCharacter(value) {
                return "Este campo debe contener al menos un caracter especial (!@#$%^&()-+)"
            }
                    
            return nil
        }
        
    func invalidPasswordConfirmation(_ value: String)-> String? {
            if value.count == 0 {
                return "Este campo es requerido"
            }
            
        if passwordText != value {
                return "Las contraseñas no coinciden"
            }
     
            return nil
    }
    
    func containsDigit(_ value: String) -> Bool {
            let reqularExpression = ".*[0-9]+.*"
            let predicate = NSPredicate(format: "SELF MATCHES %@", reqularExpression)
            return !predicate.evaluate(with: value)
    }
        
    func containsLowerCase(_ value: String) -> Bool {
        let reqularExpression = ".*[a-z]+.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", reqularExpression)
        return !predicate.evaluate(with: value)
    }
        
    func containsUpperCase(_ value: String) -> Bool {
        let reqularExpression = ".*[A-Z]+.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", reqularExpression)
        return !predicate.evaluate(with: value)
    }
    
    func containsSpecialCharacter(_ value: String) -> Bool {
        let reqularExpression = ".*[!@#$%^&()-+]+.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", reqularExpression)
        return !predicate.evaluate(with: value)
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
    
}

#Preview{
    SecondRegisterView()
}
