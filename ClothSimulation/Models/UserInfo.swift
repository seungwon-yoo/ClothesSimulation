//
//  UserInfo.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/04/23.
//

import UIKit

class UserInfo {
    static let shared = UserInfo()
    
    private(set) var uid: String?
    private(set) var email: String?
    private(set) var name: String?
    private(set) var modelFileName: String?
    
    private init() { }
    
    func setUserInfo(uid: String, email: String?, name: String?) {
        self.uid = uid
        self.email = email
        self.name = name
    }
    
    func addModeFilelName(modelFileName: String) {
        self.modelFileName = modelFileName
    }
}
