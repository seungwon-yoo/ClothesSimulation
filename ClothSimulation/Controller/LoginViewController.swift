//
//  UserLogInController.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/03/27.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var googleLoginBtn: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var warningTextField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitialView()
    }
    
    @IBAction func findingPasswordButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "비밀번호 재설정", message: "비밀번호 재설정을 위해 이메일을 입력해주세요.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { ok in
            
            Auth.auth().sendPasswordReset(withEmail: (alert.textFields?[0].text)!) { error in
                if error != nil {
                    print("wrong email")
                } else {
                    print("send email")
                    
                    let completeAlert = UIAlertController(title: "비밀번호 재설정", message: "메일이 전송되었습니다. 비밀번호를 변경한 후 로그인해 주세요.", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
                    
                    completeAlert.addAction(okAction)
                    
                    self.present(completeAlert, animated: true, completion: nil)
                }
            }
        }
        
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(ok)
        
        alert.addTextField()
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func logInPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text{
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e)
                    self.passwordTextField.replaceUnderLine(color: .red)
                    self.passwordTextField.shakeTextField()
                    self.warningTextField.text = "이메일 혹은 비밀번호가 틀렸습니다."
                } else {
                    UserInfo.shared.uid = authResult!.user.uid
                    UserInfo.shared.email = authResult!.user.email
                    FirestoreService().getUserName(uid: authResult!.user.uid) { name in
                        UserInfo.shared.name = name
                    }
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
                
                if let user = Auth.auth().currentUser {
                    UserInfo.shared.uid = user.uid
                    UserInfo.shared.email = user.email
                    UserInfo.shared.name = user.displayName
                }
                
                FirestoreService().initializeUserInfo()
                
                self.performSegue(withIdentifier: K.loginInToFitSegue, sender: self)
            }
        }
    }
}

//MARK: - Textfield functions

extension LoginViewController: UITextFieldDelegate {
    func setInitialView() {
        let image = UIImage(named: "google")
        googleLoginBtn.setImage(image, for: .normal)
        googleLoginBtn.imageView?.contentMode = .scaleAspectFill
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
}
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
