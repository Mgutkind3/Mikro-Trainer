//
//  SettingsVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 9/17/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsVC: UIViewController {

    
    @IBOutlet weak var touchSwitch: UISwitch!
    var switchState = Int()
    @IBOutlet weak var wrongPwdLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        print("user Default settings: \(UserDefaults.standard.string(forKey: "switchState"))")
        if (UserDefaults.standard.string(forKey: "switchState") == "0" || UserDefaults.standard.string(forKey: "switchState") == "" ){
            self.touchSwitch.setOn(false, animated: true)
        }else{
            self.touchSwitch.setOn(true, animated: true)
        }
        
    }
    
    //activate or deactivate thumb print scanner for identification
    @IBAction func switchChangedAct(_ sender: Any) {
        
        self.wrongPwdLabel.text = ""
        
        if (UserDefaults.standard.string(forKey: "switchState") == "0"){
            UserDefaults.standard.set("1", forKey: "switchState")
            //enter password
            let pwdAlert = UIAlertController(title: "Enter Password", message: "Please enter your password to activate Touch ID", preferredStyle: .alert)
            
            pwdAlert.addTextField { (textField) in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
            }
            
            //enter the right password
            let enterAction = UIAlertAction(title: "Enter", style: .default, handler: { (_) in
                let pwdField = pwdAlert.textFields![0] // Force unwrapping because we know it exists.
                //authentication
                Auth.auth().signIn(withEmail: "mike@gmail.com", password: pwdField.text!, completion: { user, error in
                    if let firebaseError = error{
                        print(firebaseError.localizedDescription)
                        self.wrongPwdLabel.text = String(firebaseError.localizedDescription)
                        print("cancel!")
                        self.touchSwitch.setOn(false, animated: true)
                        UserDefaults.standard.set("0", forKey: "switchState")
                        
                        return
                    }
                    
                    //if error is not printed send a success message and dismiss modal
                    print("activate Touch ID")
                    UserDefaults.standard.set(pwdField.text!, forKey: "usrPwd")
                })
//                print("Text field: \(pwdField.text)")
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                print("cancel!")
                self.touchSwitch.setOn(false, animated: true)
                UserDefaults.standard.set("0", forKey: "switchState")
            }
            
            pwdAlert.addAction(enterAction)
            pwdAlert.addAction(cancelAction)
            self.present(pwdAlert, animated: true, completion: nil)
            
        }else{
            UserDefaults.standard.set("0", forKey: "switchState")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
