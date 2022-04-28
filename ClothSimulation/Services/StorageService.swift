//
//  StorageService.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/04/28.
//

import UIKit
import FirebaseStorage

enum NetworkError: Error {
    case decodingError
    case domainError
    case urlError
}

struct Resource<T: Codable> {
    
}

class StorageService {
    let mainURL = "gs://clothsimulation-3af50.appspot.com/"
    
    func loadImage(childURL: String, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {

        let ref = Storage.storage().reference(forURL: mainURL).child(childURL)
        
        ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
            guard let data = data, error == nil else {
                completion(.failure(.urlError))
                return
            }
            
            if let image = UIImage(data: data as Data) {
                completion(.success(image))
            }
        }
    }
    
    func fetchStorageClothesList(of category: String, completion: @escaping (Result<[StorageReference], NetworkError>) -> Void) {
        let childURL = "clothes/" + category
        let url = mainURL + childURL
        
        Storage.storage().reference(forURL: url).listAll { result, error in
            guard error == nil else {
                completion(.failure(.urlError))
                return
            }
            
            completion(.success(result.items))
        }
    }
}
