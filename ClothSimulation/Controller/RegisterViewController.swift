//
//  UserRegisterController.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/03/27.
//

import UIKit
import Firebase
import GoogleSignIn

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitialView()
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    // Navigate to the ChatViewController
                    UserInfo.shared.uid = authResult!.user.uid
                    UserInfo.shared.email = authResult!.user.email
                    self.performSegue(withIdentifier: K.registerToFitSegue, sender: self)
                }
            }
        }
    }
}

//MARK: - Textfield functions

extension RegisterViewController: UITextFieldDelegate {
    func setInitialView() {
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        nameTextField.addUnderLine()
        emailTextField.addUnderLine()
        passwordTextField.addUnderLine()
    }
    
    @objc
    func keyboardWillShow(_ sender: Notification) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
    }
    
    @objc
    func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
