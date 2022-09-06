//
//  String+Extensions.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/09/06.
//

import Foundation

extension String {
    func stringToDate() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        return dateFormatter.string(from: now)
    }
}
