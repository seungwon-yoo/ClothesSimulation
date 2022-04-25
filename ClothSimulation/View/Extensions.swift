//
//  Extensions.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/03/31.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

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

extension UIViewController {
    // db에 사용자가 선택한 의상의 정보를 넣음
    func insertClothesInfo(imageInfo: ImageInfo, uid: String) {
        let db = Firestore.firestore()
        let uidReference = db.collection("users").document(uid)

        db.runTransaction({ transaction, errorPointer -> Any? in
            let uidDocument: DocumentSnapshot
            do {
                try uidDocument = transaction.getDocument(uidReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard let oldFashionArray = uidDocument.data()?[imageInfo.category] as? [Int] else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(uidDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            var oldFashionSet: Set<Int> = Set(oldFashionArray)
            oldFashionSet.insert(imageInfo.number)
            
            transaction.updateData([imageInfo.category: Array(oldFashionSet)], forDocument: uidReference)
            return nil
        }) { object, error in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
}
