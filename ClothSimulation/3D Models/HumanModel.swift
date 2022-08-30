//
//  HumanModel.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/08/27.
//

import Foundation

enum SkinColor {
    case white
    case medium
    case dark
}

class HumanModel {
    static let model = HumanModel()
    
    private(set) var modelPath: String = K.tempModel
    private(set) var skinColor: SkinColor = .medium
    
    func changeSkinColor(to color: SkinColor) {
        skinColor = color
    }
}
