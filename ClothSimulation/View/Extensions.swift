//
//  Extensions.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/03/31.
//

import UIKit

extension UITextField {
    func addUnderLine() {
        self.borderStyle = .none
        let border = CALayer()
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height-1, width: self.frame.width, height: 1)
        border.borderWidth = 1
        border.backgroundColor = UIColor.white.cgColor
        self.layer.addSublayer(border)
        self.textAlignment = .center
        self.textColor = UIColor.darkGray
        self.textAlignment = .left
    }
}
