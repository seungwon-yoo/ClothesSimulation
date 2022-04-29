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
}
