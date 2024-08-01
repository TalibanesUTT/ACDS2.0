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

    
    var body: some View {
        ZStack{
            Color("BG").ignoresSafeArea()
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                
                Text("Código de verificación")
                    .bold()
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.black)
                
                TextField("", text: limitedTextBinding($verificationText, maxLength: 6))
                    .padding(.all,10)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                    .padding(.bottom,30)
                    .keyboardType(.numberPad)
                
                Button(action: {navigateToLogin()}, label: {
                    Text("Enviar código")
                        .padding(.all, 12)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .background(Color("RedBtn"))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .bold()
                })
                
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
    
    func navigateToLogin(){
        navigationManager.resetToRoot()
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
                    do {
                        let JSONResponse = try JSONSerialization.jsonObject(with:data!) as! [String:Any]
                        let message = JSONResponse["message"] as! String
                        DispatchQueue.main.async {
                            navigateToLogin()
                        }
                    }
                    catch{
                        alertMessage = "Algo salió mal!"
                        showAlert = true
                    }
                }
                else {
                    DispatchQueue.main.async {
                        alertMessage = "No se pudo verificar el teléfono"
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
        if(!verificationText.isEmpty){
            notAbleToComplete = false
        }
        else {
            notAbleToComplete = true
        }
    }
}

#Preview {
    CodeVerifyView()
}
