//
//  UserData.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 31/07/24.
//

import Foundation

class UserData: ObservableObject {
    @Published var id: Int
    @Published var name: String
    @Published var lastName: String
    @Published var email: String
    @Published var phone_number: String
    @Published var rol_id: Int
    @Published var token: String
    @Published var signedRoute: String
    static let shared = UserData()
    let prodUrl = "http://localhost:3000"

    private init() {
        id = 0
        name = ""
        lastName = ""
        email = ""
        phone_number = ""
        rol_id = 1
        token = ""
        signedRoute = ""
        
    }
    
    func setData(_ data :[String:Any]){
        
        if let numberValue = Int(data["id"] as! String) {
            id = numberValue
        } else {
            print("No se pudo convertir la cadena a un número")
        }

        name = data["name"] as! String
        lastName = data["lastName"] as! String
        email = data["email"] as! String
        phone_number = data["phoneNumber"] as! String
        
    }
    
    func resetData() {
        id = 0
        name = ""
        lastName = ""
        email = ""
        phone_number = ""
        rol_id = 1
        token = ""
        signedRoute = ""
    }
}
