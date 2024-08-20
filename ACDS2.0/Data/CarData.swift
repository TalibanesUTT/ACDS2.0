//
//  CarData.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 05/08/24.
//

import Foundation

struct Model: Decodable {
    let brand: String
    let id: Int
    let model: String
}

struct Car: Identifiable{
    let id: String
    let color: String
    let plates: String
    let model: [String:Any]
    let owner: String
    let year: Int
    let serialNumber: String
}

struct CarDetail: Identifiable{
    let id: String
    let fileNumber: String
    let initialMileage: Int
    let notes: String
    let createDate: String
    let vehicle: [String:Any]
    let appointments: [String:Any]?
    let services: [[String:Any]]
    let detail: [String:Any]
    let history: [[String:Any]]?
    let actualStatus: String?
}

struct Service: Identifiable{
    let id: Int
    let name: String
}

struct Customer: Identifiable{
    let id: String
    let name: String
    let lastName: String
    let email: String
    let phoneNumber: String
    let role: String
    let active: Bool
}

