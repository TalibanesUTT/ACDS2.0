//
//  ContentView.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 29/07/24.
//

import SwiftUI
import Combine

class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
    
    func resetToRoot() {
        path = NavigationPath()
    }
}

struct LoginView: View {
    @State var emailText: String = ""
    @State var emailError: String? = nil
    @State var passwordError: String? = nil
    @State var passwordText: String = ""
    @State var showAlert: Bool = false
    @State var ableToLogin: Bool = true
    @State private var alertMessage = ""
    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject var userData = UserData.shared
    
    var body: some View {
        NavigationStack (path: $navigationManager.path){
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
                            limitText(&emailText, to: 100)
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
                    
                    Text("Contraseña")
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.black)
                    
                    SecureField("", text: $passwordText)
                        .onChange(of: passwordText, {
                            limitText(&passwordText, to: 30)
                            passwordError = invalidPassword(passwordText)
                            checkForm()
                        })
                        .padding(.all, 10)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        .padding((passwordError != nil) ? .top : .bottom, (passwordError != nil) ? 0 : 30)
                        .keyboardType(.default)
                        .foregroundStyle(.black)
                        .textInputAutocapitalization(.never)
                    
                    if let errorMessage = passwordError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .padding(.bottom, 30)
                    }
                    
                    Button(action: { loginRequest() }, label: {
                        Text("Iniciar sesión")
                            .padding(.all, 12)
                            .font(.footnote)
                            .frame(maxWidth: .infinity)
                            .background(Color("RedBtn"))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .bold()
                            
                    }).disabled(ableToLogin)
                    
                    Text("¿No tienes una cuenta activa?")
                        .italic()
                        .opacity(1)
                        .foregroundColor(Color.gray.opacity(0.6))
                        .font(.footnote)
                    
                    Button(action: {
                        navigateToRegister()
                    }, label: {
                        Text("Registrate aqui")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(Color("RedBtn"))
                            .underline()
                            .font(.footnote)
                    })
                    
                    Spacer()
                    
                    Text("¿Tienes problemas para iniciar sesión?")
                        .italic()
                        .opacity(1)
                        .foregroundColor(Color.gray.opacity(0.6))
                    
                    Button(action: {
                        navigateToRecoverPassword()
                    }, label: {
                        Text("Recuperar contraseña")
                            .foregroundColor(Color("RedBtn"))
                            .underline()
                            .font(.footnote)
                            .padding(.bottom, 0)
                    })
                    
                }.padding(20)
                    
                    .navigationDestination(for: String.self){ destination in
                        switch destination {
                        case "Home":
                            MainView().navigationBarBackButtonHidden(true)
                            
                        case "FirstRegister":
                            FirstRegisterView().navigationBarBackButtonHidden(true)
                            
                        case "SecondRegister":
                            SecondRegisterView().navigationBarBackButtonHidden(true)
                            
                        case "Code":
                            CodeVerifyView().navigationBarBackButtonHidden(true)
                            
                        case "Recover":
                            PassRecoverView()
                            
                        case "Mechanic":
                            MechanicHome().navigationBarBackButtonHidden(true)

                        default:
                            EmptyView()
                            
                    }
                }
                  
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                WatchConnector.shared.startSession()
                if (!userData.token.isEmpty){
                    navigateToHome()
                }
            }
        }
    }
             
    func navigateToHome(){
        navigationManager.path.append("Home")
    }
    
    func navigateToRegister(){
        navigationManager.path.append("FirstRegister")
    }
    
    func navigateToRecoverPassword(){
        navigationManager.path.append("Recover")
    }
    
    func navigateToMechanicView(){
        navigationManager.path.append("Mechanic")
    }
    
    //MARK: - Requests
    
    func loginRequest(){
        let url = URL(string: "\(userData.prodUrl)/auth/login")!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
                
                  
        let requestBody: [String: Any] = [
            "email": emailText,
            "password": passwordText
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
                            self.userData.token = JSONResponse["data"] as! String
                            print(self.userData.token)
                            WatchConnector.shared.sendToken(self.userData.token)
                            getProfile()
                         
                        }
                    }
                    catch{
                        alertMessage = "Algo salió mal"
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
    
    func getProfile() {
        let url = URL(string: "\(userData.prodUrl)/profile")!
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
                        let id = JSONResponse["id"] as! String
                        DispatchQueue.main.async {
                            
                            if let numberValue = Int(id) {
                                self.userData.id = numberValue
                            } else {
                                print("No se pudo convertir la cadena a un número")
                            }
                            
                            self.userData.name = JSONResponse["name"] as! String
                            self.userData.lastName = JSONResponse["lastName"] as! String
                            self.userData.email = JSONResponse["email"] as! String
                            self.userData.phone_number = JSONResponse["phoneNumber"] as! String
                            if (JSONResponse["role"] as! String == "customer"){
                                navigateToHome()
                            }
                            else{
                                navigateToMechanicView()
                            }
                        }
                    }
                    catch{
                        alertMessage = "Algo salió mal"
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
    
    func invalidPassword(_ value: String)->String?{
        if value.count == 0 {
            return "Este campo es requerido"
        }
        
        if value.count < 8 {
            return  "Este campo debe tener al menos 8 caracteres"
        }
                
        return nil
    }
    
    func checkForm() {
        if (emailError == nil && passwordError == nil) && (!emailText.isEmpty && !passwordText.isEmpty) {
            ableToLogin = false
        } else {
            ableToLogin = true
        }
    }
    
    func limitedTextBinding(_ binding: Binding<String>, maxLength: Int) -> Binding<String> {
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

extension String {
    func limited(to length: Int) -> String {
        return self.count > length ? String(self.prefix(length)) : self
    }
}

func limitText<T>(_ value: inout T, to upper: Int) where T: StringProtocol {
    if value.count > upper {
        value = String(value.prefix(upper)) as! T
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let nav = NavigationManager()
        LoginView()
            .environmentObject(nav)
    }
}
