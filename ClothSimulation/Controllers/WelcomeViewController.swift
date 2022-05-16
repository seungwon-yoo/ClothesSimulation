//
//  WelcomeViewController.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/02/19.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.UIButtonsAreHidden(true, button1: registerButton, button2: loginButton)
        
        animateTitleLabel(of: titleLabel)
        
        CategoryViewModel.shared.setupUI()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3.0) {
            self.textLabel.isHidden = true
            self.checkLogin()
        }
    }
}

extension WelcomeViewController {
    
    // animate an titleLabel
    func animateTitleLabel(of titleLabel: UILabel) {
        titleLabel.text = ""
        
        var charIndex = 0.0
        
        let titleText = K.appName
        
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.2 * charIndex, repeats: false) { timer in
                self.titleLabel.text?.append(letter)
            }
            charIndex += 1.0
        }
    }
    
    // 로그인이 되어있던 경우 바로 메인 화면으로 이동
    func checkLogin() {
        if let user = Auth.auth().currentUser {
            self.performSegue(withIdentifier: K.welcomeToFitSegue, sender: self)
            print("You're sign in as \(user.uid), email: \(user.email ?? "no email")")
            
            // 미리 옷장에 옷 넣어두기
            ClothesViewModel.shared.fetchClothesInfo()
        } else {
            self.UIButtonsAreHidden(false, button1: self.registerButton, button2: self.loginButton)
        }
    }
    
    func UIButtonsAreHidden(_ isHidden: Bool, button1: UIButton, button2: UIButton) {
        button1.isHidden = isHidden
        button2.isHidden = isHidden
    }
}
