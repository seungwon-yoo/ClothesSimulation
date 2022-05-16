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
    let db = Firestore.firestore()
    
    func getUserName(uid: String, completion: @escaping (_ name: String) -> Void) {
        let uidRef = db.collection("users").document(uid)
        var name: String?
        
        uidRef.getDocument { document, error in
            if let document = document, document.exists {
                name = document.data()!["name"] as? String
                completion(name!)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    

func initializeUserInfo() {
    // Firestore에 사용자 의상 정보 초기화
    if let uid = UserInfo.shared.uid {
        let uidRef = db.collection("users").document(uid)
        
        uidRef.getDocument { document, error in
            if let document = document, document.exists {
                print("Document exist")
            } else {
                print("Document does not exist")
                
                self.initializeUserDB(uid: uid, email: UserInfo.shared.email!, name: UserInfo.shared.name!)
            }
        }
    }
}

func initializeUserDB(uid: String, email: String, name: String) {
    var data: [String: Any] = ["email": email, "name": name]
    for cat in K.categoryList {
        data[cat] = []
    }
    
    Firestore.firestore().collection("users").document(uid).setData(data)
}

func fetchUserCloset(uid: String, completion: @escaping (Result<[String: Any], DBError>) -> Void) {
    let uidRef = db.collection("users").document(uid)
    
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
    let uidReference = db.collection("users").document(uid)
    
    db.runTransaction({ transaction, errorPointer -> Any? in
        let uidDocument: DocumentSnapshot
        do {
            try uidDocument = transaction.getDocument(uidReference)
        } catch let fetchError as NSError {
            errorPointer?.pointee = fetchError
            return nil
        }
        
        guard let oldFashionArray = uidDocument.data()?[imageInfo.category] as? [String] else {
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
        
        var oldFashionSet: Set<String> = Set(oldFashionArray)
        oldFashionSet.insert(imageInfo.name)
        
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
    let uidReference = db.collection("users").document(uid)
    
    db.runTransaction({ transaction, errorPointer -> Any? in
        let uidDocument: DocumentSnapshot
        do {
            try uidDocument = transaction.getDocument(uidReference)
        } catch let fetchError as NSError {
            errorPointer?.pointee = fetchError
            return nil
        }
        
        guard var oldFashionArray = uidDocument.data()?[imageInfo.category] as? [String] else {
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
        
        for (i, name) in oldFashionArray.enumerated() {
            if name == imageInfo.name {
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
