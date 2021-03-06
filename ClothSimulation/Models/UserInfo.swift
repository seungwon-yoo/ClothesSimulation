//
//  UserInfo.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/04/23.
//

import UIKit

class UserInfo {
    static let shared = UserInfo()
    var uid: String?
    var email: String?
    var name: String?
    
    private init() { }
    
    private init(uid: String, email: String, name: String) {
        self.uid = uid
        self.email = email
        self.name = name
    }
}
