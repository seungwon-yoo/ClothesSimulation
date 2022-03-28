//
//  WelcomeViewController.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/02/19.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = ""
        var charIndex = 0.0
        let titleText = K.appName
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { (timer) in
                self.titleLabel.text?.append(letter)
            }
            charIndex += 1
        }
    }
    
    @IBAction func startPressed(_ sender: UIButton) {
        if let user = Auth.auth().currentUser {
            self.performSegue(withIdentifier: K.welcomeToFitSegue, sender: self)
            print("You're sign in as \(user.uid), email: \(user.email ?? "no email")")
        } else {
            self.performSegue(withIdentifier: K.welcomeToLogInSegue, sender: self)
        }
    }
    
}
