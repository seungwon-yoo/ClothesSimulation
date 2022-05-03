//
//  FirestoreService.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/04/29.
//

import UIKit
import Firebase

enum DBError: Error {
    case uidError
    case emptyError
}

class FirestoreService {
    func fetchUserCloset(uid: String, completion: @escaping (Result<[String: Any], DBError>) -> Void) {
        let uidRef = Firestore.firestore().collection("users").document(uid)
        
        uidRef.getDocument { document, error in
            guard let document = document, error == nil else {
                completion(.failure(.uidError))
                return
            }
            
            guard document.exists else {
                completion(.failure(.emptyError))
                return
            }
            
            completion(.success(document.data()!))
        }
    }
    
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
    
    func deleteClothesInfo(imageInfo: ImageInfo, uid: String) {
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

            guard var oldFashionArray = uidDocument.data()?[imageInfo.category] as? [Int] else {
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
            
            for (i, num) in oldFashionArray.enumerated() {
                if num == imageInfo.number {
                    oldFashionArray.remove(at: i)
                }
            }
            
            transaction.updateData([imageInfo.category: oldFashionArray], forDocument: uidReference)
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
