//
//  ProfileView.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 31/07/24.
//

import SwiftUI

struct ProfileView: View {
    @State var lastName: String = "Zapata"
    @State var email: String = "luiszapata0815@gmail.com"
    @State var phone: String = "8713530073"
    @State var isEdit: Bool = false
    @State var isChangingPassword: Bool = false
    @State var actualPassword: String = ""
    @State var newPassword: String = ""
    @State var confirmNewPassword: String = ""
    @State var showAlert: Bool = false
    @State var showSecondAlert: Bool = false
    @State var alertMessage: String = ""
    @State var alertTitle: String = "Aviso"
    @State var initialEmail: String = ""
    @State var initialPhone: String = ""
    @State var valueChanged : String = ""
    @State var finalAlert: Bool = true
    @State var forEditing: Bool = false
    @State var emailError: String? = nil
    @State var phoneError: String? = nil
    @State var nameError: String? = nil
    @State var lastNameError: String? = nil
    @State var passwordError: String? = nil
    @State var notAbleToChange: Bool = true
    @ObservedObject var userData = UserData.shared
    

    
    var body: some View {
        ZStack{
            Color("BG").ignoresSafeArea()
            VStack{
                Image("PFP")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 200)
                Text("Hola, \(userData.name) \(userData.lastName)!")
                    .font(.largeTitle)
                    .foregroundStyle(.black)
                
                Spacer()
                
                if (isChangingPassword){
                    
                    Text("Contraseña actual").frame(maxWidth: .infinity,alignment: .leading)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.black)
                    
                    SecureField("", text: $actualPassword)
                        .padding(.all, 10)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        .padding(.bottom, 30)
                        .keyboardType(.default)
                        .foregroundStyle(.black)
                        .font(.subheadline)
                    
                    if let errorMessage = passwordError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 30)
                    }
                    
                    Text("Contraseña nueva")
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.black)
                    
                    SecureField("", text: $newPassword)
                        .padding(.all, 10)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        .padding(.bottom, 30)
                        .keyboardType(.default)
                        .foregroundStyle(.black)
                        .font(.subheadline)
                
                    Text("Confirmar contraseña")
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.black)
                    
                    SecureField("", text: $confirmNewPassword)
                        .padding(.all, 10)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        .padding(.bottom, 30)
                        .keyboardType(.default)
                        .foregroundStyle(.black)
                        .font(.subheadline)
                    
                } else {
                    
                    HStack{
                        VStack{
                            Text("Nombre").frame(maxWidth: .infinity,alignment: .leading)
                                .font(.headline)
                                .bold()
                                .foregroundStyle(.black)
                            
                            TextField("", text: limitedTextBinding($userData.name, maxLength: 30))
                                .padding(.all, 10)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(10)
                                .padding((nameError != nil) ? .top: .bottom, (nameError != nil) ? 0 : 30)
                                .keyboardType(.default)
                                .foregroundStyle(.black)
                                .font(.subheadline)
                                .disabled(!isEdit)
                            
                            if let errorMessage = nameError {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity,alignment: .leading)
                                    .padding(.bottom, 60)
                            }
                            
                        }
                        VStack{
                            Text("Apellidos").frame(maxWidth: .infinity,alignment: .leading)
                                .font(.headline)
                                .bold()
                                .foregroundStyle(.black)
                            
                            TextField("",text: limitedTextBinding($userData.lastName, maxLength: 60))
                                .padding(.all, 10)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(10)
                                .padding((lastNameError != nil) ? .top: .bottom, (lastNameError != nil) ? 0 : 30)
                                .keyboardType(.default)
                                .foregroundStyle(.black)
                                .font(.subheadline)
                                .disabled(!isEdit)
                            
                            if let errorMessage = lastNameError {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity,alignment: .leading)
                                    .padding(.bottom, 30)
                            }
                        }
                    }
                    
                    Text("Correo electrónico")
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.black)
                    
                    TextField("", text: limitedTextBinding($userData.email, maxLength: 100))
                        .padding(.all, 10)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        .padding((emailError != nil) ? .top: .bottom, (emailError != nil) ? 0 : 30)
                        .keyboardType(.default)
                        .foregroundStyle(.black)
                        .font(.subheadline)
                        .disabled(!isEdit)
                    
                    if let errorMessage = emailError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .padding(.bottom, 30)
                    }
                    
                    Text("Número de teléfono")
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.black)
                    
                    TextField("", text: limitedTextBinding($userData.phone_number, maxLength: 10))
                        .padding(.all, 10)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        .padding((phoneError != nil) ? .top : .bottom, (phoneError != nil) ? 0 : 30)
                        .keyboardType(.numberPad)
                        .foregroundStyle(.black)
                        .font(.subheadline)
                        .disabled(!isEdit)
                    
                    if let errorMessage = phoneError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 30)
                    }
                    
                }
            
                Spacer()
                
                HStack{
                    
                    if (isEdit || isChangingPassword){
                        Button(action: {
                            isEdit = false
                            isChangingPassword = false
                        }, label: {
                            Text("Cancelar")
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray)
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                                .bold()
                                .font(.footnote)
                        })
                        
                        Button(action: { saveChanges()}, label: {
                            Text("Confirmar")
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                                .bold()
                                .font(.footnote)
                        })
                        
                    }else{
                        Button(action: {
                            isEdit = !isEdit }, label: {
                            Text("Editar perfil")
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray)
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                                .bold()
                                .font(.footnote)
                        })
                        
                        Button(action: {isChangingPassword = true}, label: {
                            Text("Cambiar contraseña")
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(Color("RedBtn"))
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                                .bold()
                                .font(.footnote)
                        })
                    }
                }
                
            }
            .padding()
            .onAppear(){
                initialEmail = userData.email
                initialPhone = userData.phone_number
            }
            .alert(isPresented:$showAlert){
                if (!forEditing){
                    Alert(
                        title: Text(alertTitle),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK").foregroundStyle(.blue))
                    )
                }
                else{
                    Alert(
                        title: Text(alertTitle),
                        message: Text(alertMessage),
                        primaryButton: .default(Text("Ok").foregroundStyle(.blue), action:{ editProfileRequest()} ),
                        secondaryButton: .cancel(Text("Cancelar").foregroundStyle(.red), action: {
                            cancelChangedValue()
                            editProfileRequest()
                        })
                    )
                }
            }
        }
    }
    
    //MARK: - Requests
    
    
    func editProfileRequest(){
        let url = URL(string: "http://localhost:3000/user-management/updateProfile/\(userData.id)")!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "PUT"
        request.addValue("Bearer " + userData.token, forHTTPHeaderField: "Authorization")
      
        let requestBody: [String: Any] = [
            "name": userData.name,
            "lastName": userData.lastName,
            "phoneNumber": userData.phone_number,
            "email": userData.email,
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
                        let msg = JSONResponse["message"] as! String
                        DispatchQueue.main.async {
                            forEditing = false
                            alertMessage = msg
                            showAlert = true
                            setData(JSONResponse["data"] as! [String : Any])
                            isEdit = false
                        }
                    }
                    catch {
                        forEditing = false
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
                            forEditing = false
                            alertMessage = message
                            showAlert = true
                        }
                    }
                    catch {
                        forEditing = false
                        alertMessage = "Algo salió mal!"
                        showAlert = true
                    }
                }
            }
        }
        task.resume()
    }
    
    func changePasswordRequest(){
        let url = URL(string: "http://localhost:3000/user-management/updatePassword/\(userData.id)")!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "PUT"
        request.addValue("Bearer " + userData.token, forHTTPHeaderField: "Authorization")
    
        let requestBody: [String: Any] = [
            "actualPassword": actualPassword,
            "newPassword": newPassword,
            "passwordConfirmation": confirmNewPassword,
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
                        let msg = JSONResponse["message"] as! String
                        DispatchQueue.main.async {
                            forEditing = false
                            actualPassword = ""
                            confirmNewPassword = ""
                            newPassword = ""
                            alertMessage = msg
                            showAlert = true
                            isEdit = false
                        }
                    }
                    catch{
                        forEditing = false
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
                            forEditing = false
                            alertMessage = message
                            showAlert = true
                        }
                    }
                    catch{
                        forEditing = false
                        alertMessage = "Algo salió mal!"
                        showAlert = true
                    }
                }
            }
        }
        task.resume()

    }
    
    //MARK: - Utilities
    
    func setData(_ data: [String:Any]){
        userData.name = data["name"] as! String
        userData.lastName = data["lastName"] as! String
        userData.email = data["email"] as! String
        userData.phone_number = data["phoneNumber"] as! String
        
        initialEmail = userData.email
        initialPhone = userData.phone_number
    }
    
    func saveChanges(){
        if (isChangingPassword){
            
            if (newPassword != confirmNewPassword){
                alertTitle = "Error"
                alertMessage = "Las contraseñas no coinciden"
                showAlert = true
            } else{
                changePasswordRequest()
            }
            
        }
        else{
            forEditing = true
            alertTitle = "Aviso"
            if (userData.email != initialEmail || userData.phone_number != initialPhone)
            {
                alertMessage = "Estás a punto de modificar tu correo electrónico o número de telefono. Por tu seguridad, esto desactivara momentáneamente tu cuenta hasta que verifiques tus nuevos datos. ¿Deseas continuar?"
                showAlert = true
            }
            else {
                editProfileRequest()
            }
        }
    }
    
    func cancelChangedValue(){
        userData.email = initialEmail
        userData.phone_number = initialPhone
    }
    
    //MARK: - Validations
    
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
            
        if newPassword != value {
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
    
    func checkForm(){
        if (isChangingPassword){
            if ((passwordError == nil) && (!newPassword.isEmpty  && !actualPassword.isEmpty && !confirmNewPassword.isEmpty)){
                notAbleToChange = false
            }
            else {
                notAbleToChange = true
            }
        }
        else{
            if ((nameError == nil && lastNameError == nil && emailError == nil && phoneError == nil) && (!userData.name.isEmpty  && !userData.lastName.isEmpty && !userData.email.isEmpty && !userData.phone_number.isEmpty)){
                notAbleToChange = false
            }
            else {
                notAbleToChange = true
            }
                
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
    ProfileView()
}
