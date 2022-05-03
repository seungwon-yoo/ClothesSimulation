//
//  Extensions.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/03/31.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

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
