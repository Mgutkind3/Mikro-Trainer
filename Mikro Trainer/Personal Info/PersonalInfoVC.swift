//
//  PersonalInfoVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 5/15/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol SignOutMethod{
    func endSession()
}

class PersonalInfoVC: UIViewController {

    var delegate:SignOutMethod?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarItem.title = "Me"
        self.navigationItem.title = "Personal Info"
        self.tabBarController?.tabBar.isHidden = true

        // Do any additional setup after loading the view.
    }
    
    //function to sign out of user profile
    @IBAction func signOutBtn(_ sender: Any) {
        print("Goodbye")
            do {
            try Auth.auth().signOut()
            } catch{
            print("problems logging out")
            }
        self.delegate?.endSession()
        self.navigationController?.popViewController(animated: true)
    }
    
    //go to settings page
    @IBAction func settingsPage(_ sender: Any) {
        print("settings")
        //space to enable biometric security
        //https://codeburst.io/biometric-authentication-using-swift-bb2a1241f2be
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
