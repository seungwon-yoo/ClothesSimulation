//
//  HumanModelInfo.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/09/12.
//

import Foundation

class HumanModelInfo {
    static var shared = HumanModelInfo()
    
    var modelName: String?
    
    private init() {}
    
    func changeCurrentHumanModel(modelName: String) {
        self.modelName = modelName
    }
}
