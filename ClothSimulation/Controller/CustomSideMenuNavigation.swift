//
//  CustomSideMenuNavigation.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/04/21.
//

import UIKit
import SideMenu

class CustomSideMenuNavigation: SideMenuNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.presentationStyle = .menuSlideIn
        self.leftSide = true
    }
    
}
