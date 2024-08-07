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

