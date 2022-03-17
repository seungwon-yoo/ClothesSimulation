//
//  Settings.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/02/21.
//

import Foundation

struct Settings: Codable {
    let clothes: [Clothes]
}

struct Clothes: Codable {
    let category: String
    let image: String
}
