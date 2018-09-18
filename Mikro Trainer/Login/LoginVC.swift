//
//  LoginVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 5/15/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit
import FirebaseAuth
import LocalAuthentication

class LoginVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginErrorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        print("user email: \(UserDefaults.standard.string(forKey: "emailCred"))")
        if(UserDefaults.standard.string(forKey: "switchState") == "1"){
            print("use touch id")
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Use Touch ID to sign in"
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                    [unowned self] (success, authenticationError) in
                    
                    DispatchQueue.main.async {
                        if success {
                            let email = UserDefaults.standard.string(forKey: "emailCred")!
                            let pwd = UserDefaults.standard.string(forKey: "usrPwd")!
                            
                            //attempt to sign in using firebase authentication
                            Auth.auth().signIn(withEmail: email, password: pwd, completion: { user, error in
                                if let firebaseError = error{
                                    print(firebaseError.localizedDescription)
                                    self.loginErrorLabel.text = String(firebaseError.localizedDescription)
                                    return
                                }
                                
                                //if error is not printed send a success message and dismiss modal
                                print("Logged in!")
                                self.dismiss(animated: true, completion: nil)
                            })
                            
                            
                            print("unlocked!")
                            //attempt to sign in using firebase authentication

                        } else {
                            print("not unlocked!")
                        }
                    }
                }
            } else {
                // no biometry
            }//end of bio metrics
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInButton(_ sender: Any) {
        let emailLogin = emailTextField.text
        let pwdLogin = passwordTextField.text
        loginErrorLabel.text = ""
        
        //make sure all possible fields are populated
        if  emailLogin == "" || pwdLogin == "" {
            loginErrorLabel.text = "Please populate all required fields"
            return
        }
        
        //attempt to sign in using firebase authentication
        Auth.auth().signIn(withEmail: emailLogin!, password: pwdLogin!, completion: { user, error in
            if let firebaseError = error{
                print(firebaseError.localizedDescription)
                self.loginErrorLabel.text = String(firebaseError.localizedDescription)
                return
            }
            
            //if error is not printed send a success message and dismiss modal
            print("Logged in!")
            UserDefaults.standard.set(emailLogin!, forKey: "emailCred")
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    //register for a new accounts
    @IBAction func createNewAccountButton(_ sender: Any) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "NewAccountVC") as! NewAccountVC
            self.present(vc, animated: true, completion: nil)
    }



}
