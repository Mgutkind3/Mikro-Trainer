//
//  ViewController.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 5/15/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

//dont forget to change firebase authentication for database use to being active again

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MainMenu: UIViewController {
    
    //https://resizeappicon.com/ great resource for app sizes
    var ref: DatabaseReference?
    var sessionLoginBool = false //change back to false when i want sign in service
    var userID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //firebase reference created
        self.title = "Mikro Trainer"
        
        ref = Database.database().reference()
        userID = String(Auth.auth().currentUser!.uid)
    }
    
    //function to make the user sign in if they havent signed in yet
    override func viewDidAppear(_ animated: Bool) {
        if sessionLoginBool == false {
            //set flag that workouts has started to deactivated
            UserDefaults.standard.set("0", forKey: flags.hasStartedFlag)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            navigationController?.present(vc, animated: true, completion: nil)
        }
        sessionLoginBool = true
    }

    @IBAction func personalInfoButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PersonalInfoVC") as! PersonalInfoVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func myExercisesButton(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MyExercisesVC") as! MyExercisesVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func MyWorkoutsButton(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MyWorkoutsVC") as! MyWorkoutsVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//function to dismiss keyboard when not in use (after class)
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

