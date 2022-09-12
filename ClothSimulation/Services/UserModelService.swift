//
//  UserModelService.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/07/05.
//

import UIKit
import Alamofire

class UserModelService {
    
    static let shared = UserModelService()
    
    var userModelPath: Observable<URL?> = Observable(nil)
    
    init() {
        if let path = self.getFilePathInDocuments(fileName: "my_mesh.obj") {
            userModelPath.value = try! path.asURL()
        }
    }
    
    func getUserModel(_ image: UIImage, completion: @escaping () -> Void) {
        let url = K.flaskURL + "createUserModel"
        let headers: HTTPHeaders = ["Content-type": "multipart/form-data"]
        
        AF.upload(multipartFormData: { multipart in
            if let imageData = image.pngData() {
                multipart.append(imageData, withName: "file", fileName: "\(UserInfo.shared.uid!).png", mimeType: "image/png")
            }
        },
                  to: url,
                  method: .post,
                  headers: headers).responseJSON { response in
            
            switch response.result {
            case .success:
                print("Success")
                guard let result = response.data else { return }
                do {
                    let decoder = JSONDecoder()
                    
                    let json = try decoder.decode(SceneModel.self, from: result)
                    self.getTempUserModel(url: json.url)
                    completion()
                } catch {
                    print("error!\(error)")
                }
                
            case .failure(let e):
                print(e)
            }
        }
    }
    
    func getFilePathInDocuments(fileName:String) -> String? {
        let path        = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url         = URL(fileURLWithPath: path)
        let fileManager = FileManager.default
        let filePath    = url.appendingPathComponent(fileName).path
        
        if (fileManager.fileExists(atPath: filePath)) {
            return filePath
        }else{
            return nil
        }
    }
    
    func getTempUserModel(url: String) {
        let fileName = "yyyy_MM_dd_HH_mm_ss".stringToDate() + ".obj"
        
        let destinationPath: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            let fileURL = documentsURL.appendingPathComponent(fileName)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        let url = K.flaskURL + url
        AF.download(url, to: destinationPath)
            .downloadProgress { progress in
            }
            .responseData { response in
                switch response.result {
                case .success:
                    print("Success")
                    // self.userModelPath.value = self.getFilePathInDocuments(fileName: "my_mesh.obj")
                    self.userModelPath.value = response.fileURL
                    
                    // 이 부분에 코어데이터에 저장하는 코드 넣기
                    let human =  Human(name: fileName)
                    
                    PersistenceManager.shared.insertHumanModel(human: human)
                case .failure(let e):
                    print(e)
                }
            }
    }
    
    func getModelToPutClothes(clothes_name: String) {
        let destinationPath: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0];
            let fileURL = documentsURL.appendingPathComponent(clothes_name + ".obj")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        let url = K.flaskURL + "putClothes/" + clothes_name
        AF.download(url, to: destinationPath)
            .downloadProgress { progress in
            }
            .responseData { response in
                switch response.result {
                case .success:
                    print("Success")
                    // self.userModelPath.value = self.getFilePathInDocuments(fileName: "my_mesh.obj")
                    // self.userModelPath.value = response.fileURL
                    // response.fileURL -> 의상을 입은 모델이 저장된 경로
                    // 해당 경로를 set3DModel로 보내야 함.
                case .failure(let e):
                    print(e)
                }
            }
    }
}

