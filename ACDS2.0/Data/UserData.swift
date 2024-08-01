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
}
