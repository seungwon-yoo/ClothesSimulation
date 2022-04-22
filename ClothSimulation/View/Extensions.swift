//
//  Extensions.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/03/31.
//

import UIKit

extension UITextField {
    func addUnderLine(color: UIColor = .lightGray) {
        self.borderStyle = .none
        let border = CALayer()
        border.setValue(1, forKey: "underline")
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height-1, width: self.frame.width, height: 1)
        border.borderWidth = 1
        border.backgroundColor = UIColor.white.cgColor
        self.layer.addSublayer(border)
        self.textAlignment = .center
        self.textColor = UIColor.darkGray
        self.textAlignment = .left
    }
    
    func changeUnderLineColor() {
        self.layer.backgroundColor = UIColor.red.cgColor
    }
    
    func replaceUnderLine(color: UIColor) {
        for sublayer in self.layer.sublayers! {
            if let key = sublayer.value(forKey: "underline") {
                if key as! Int == 1 {
                    sublayer.borderColor = UIColor.red.cgColor
                }
            }
        }
    }
    
    // TextField 흔들기 애니메이션
    func shakeTextField() -> Void{
        UIView.animate(withDuration: 0.2, animations: {
            self.frame.origin.x -= 10
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: {
                self.frame.origin.x += 20
             }, completion: { _ in
                 UIView.animate(withDuration: 0.2, animations: {
                     self.frame.origin.x -= 10
                })
            })
        })
    }
}
