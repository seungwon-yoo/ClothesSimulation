//
//  UserLogInController.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/03/27.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var googleSignInBtn: GIDSignInButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleSignInBtn.style = .wide
    }
    
    @IBAction func logInPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text{
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e)
                } else {
                    self.performSegue(withIdentifier: K.loginSegue, sender: self)
                }
            }
        }
    }
}
