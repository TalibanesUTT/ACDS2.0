//
//  CodeVerifyView.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 31/07/24.
//

import SwiftUI

struct CodeVerifyView: View {
    @State var verificationText: String = ""
    @State var notAbleToComplete: Bool = true
    @EnvironmentObject var navigationManager: NavigationManager
    @State var showAlert: Bool = false
    @State private var alertMessage = ""
    @ObservedObject var userData = UserData.shared
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var disableResend: Bool = true
    @State var countDown: TimeInterval = 10
    @State var titleAlert: String = "Error"
    @State var fromAdmin: Bool = false

    
    var body: some View {
        ZStack{
            Color("BG").ignoresSafeArea()
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                
                Text("Es necesario verificar tu cuenta, por lo cual se enviará un correo a \(userData.email) y tras confirmarlo, recibirás un código de verificación a tu número de teléfono.")
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                    .font(.title2)
                    .foregroundStyle(.black)
                    
                
                Text("Código de verificación")
                    .bold()
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.black)
                
                TextField("", text: $verificationText)
                    .onChange(of: verificationText, {
                        limitText(&verificationText, to: 6)
                        checkForm()
                    })
                    .padding(.all,10)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                    .padding(.bottom,30)
                    .keyboardType(.numberPad)
                    .foregroundStyle(.black)
                
                Button(action: {verifyCodeRequest()}, label: {
                    Text("Enviar código")
                        .padding(.all, 12)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .background(Color("RedBtn"))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .bold()
                        .padding(.bottom,10)
                })
                
                HStack {
                    
                    if (!fromAdmin){
                        VStack{
                            Text("")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            Button(action: { navigateToRegister() }, label: {
                                Text("¿Tus datos son incorrectos?")
                                    .font(.footnote)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            })
                            .foregroundStyle(.black)
                        }
                    }
                   
                    VStack {
                        Text(formattedTime())
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .onReceive(timer, perform: { _ in
                                if countDown > 0 && disableResend {
                                    countDown -= 1
                                }
                                else{
                                    disableResend = false
                                }
                            })
                            .foregroundStyle(.black)
                        
                        Button(action: {resendVerificationCode()}, label: {
                            Text("Reenviar codigo")
                                .font(.footnote)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                
                        })
                        .disabled(disableResend)
                        
                    }
                    
                }
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
    
    func navigateToRegister(){
        navigationManager.path.append("FirstRegister")
    }
    
    func navigateToLogin(){
        navigationManager.resetToRoot()
    }
    
    func navigateToHome(){
        navigationManager.path.append("Home")
    }
    
    func navigateToMechanic(){
        navigationManager.path.append("Mechanic")
    }
    //MARK: - Requests
    
    func verifyCodeRequest(){
        let url = URL(string: userData.signedRoute + "&code=" + verificationText)!
                var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
                request.httpMethod = "GET"
                
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error en el request: \(error)")
                    return
                }
            
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    do
                    {
                        let JSONResponse = try JSONSerialization.jsonObject(with:data!) as! [String:Any]
                        
                        let token = JSONResponse["data"] as? String
                        if (!((token?.isEmpty) == nil)){
                            DispatchQueue.main.async {
                                userData.token = token!
                                getProfile()
                            }
                        }
                        else{
                            DispatchQueue.main.async {
                                navigateToLogin()
                            }
                        }
                    }
                    catch{
                        print(error)
                        DispatchQueue.main.async {
                            titleAlert = "Error"
                            alertMessage = "No se pudo verificar "
                            showAlert = true
                        }
                    }
                    
                }
                else {
                    print("error")
                    DispatchQueue.main.async {
                        titleAlert = "Error"
                        alertMessage = "No se pudo verificar "
                        showAlert = true
                    }
                }
            }
        }
        task.resume()
    }
    
    func resendVerificationCode(){
        let url = URL(string: "\(userData.prodUrl)/auth/resendVerificationCode/\(userData.id)")!
                var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
                request.httpMethod = "GET"
                
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
                            countDown = 10
                            disableResend = true
                        }
                    }
                    catch{
                        titleAlert = "Error"
                        alertMessage = "Algo salió mal!"
                        showAlert = true
                    }
                }
                else {
                    DispatchQueue.main.async {
                        titleAlert = "Error"
                        countDown = 10
                        disableResend = true
                        alertMessage = "No se pudo reenviar el código"
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
                                navigateToMechanic()
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
    
    func checkForm(){
        if(!verificationText.isEmpty){
            notAbleToComplete = false
        }
        else {
            notAbleToComplete = true
        }
    }
    
    //MARK: - Utilities
    
    func formattedTime () -> String {
        let minutes = Int(countDown)/60
        let seconds = Int(countDown)%60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}

#Preview {
    CodeVerifyView()
}
