//
//  ActivityIndicatorService.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/05/05.
//

import UIKit
import NVActivityIndicatorView

class ActivityIndicatorService {
    // lazy: 사용되기 전까지 연산되지 않는다. 로딩이 불필요한 경우에도 메모리를 잡아먹지 않는다.
    lazy var loadingBgView: UIView = {
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        bgView.backgroundColor = .gray
        
        return bgView
    }()
    
    lazy var activityIndicator: NVActivityIndicatorView = {
        // ✅ activity indicator 설정
        let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40),
                                                        type: .ballBeat,
                                                        color: .lightGray,
                                                        padding: .zero)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        return activityIndicator
    }()
    
    lazy var message: UILabel = {
        let message = UILabel()
        message.text = "모델을 생성하는 중입니다. 잠시만 기다려주세요."
        // message.font = UIFont.systemFont(ofSize: 20.0)
        message.textColor = .white
        
        message.translatesAutoresizingMaskIntoConstraints = false
        
        return message
    }()
    
    func setActivityIndicator(view: UIView) {
        // 불투명 뷰 추가
        view.addSubview(loadingBgView)
        
        // 레이블 추가
        loadingBgView.addSubview(message)
        
        // activity indicator 추가
        loadingBgView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            message.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            message.centerYAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10)
        ])
        
        // 애니메이션 시작
        activityIndicator.startAnimating()
    }
    
    func endActivityIndicator(view: UIView) {
        activityIndicator.stopAnimating()
        loadingBgView.removeFromSuperview()
    }
}
