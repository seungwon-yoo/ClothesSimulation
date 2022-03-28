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
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func logInPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text{
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e)
                } else {
                    self.performSegue(withIdentifier: K.loginInToFitSegue, sender: self)
                }
            }
        }
    }
    
    @IBAction func googleLogInPressed(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let signInConfig = GIDConfiguration.init(clientID: clientID)
                
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }

            guard let authentication = user?.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!, accessToken: authentication.accessToken)
            // access token 부여 받음

            // 파베 인증정보 등록
            Auth.auth().signIn(with: credential) { _, _ in
                // token을 넘겨주면, 성공했는지 안했는지에 대한 result값과 error값을 넘겨줌
                self.performSegue(withIdentifier: K.loginInToFitSegue, sender: self)
            }
        }
    }
}
