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

class MainMenu: UIViewController, SignOutMethod {
    
    //https://resizeappicon.com/ great resource for app sizes
    var ref: DatabaseReference?
    var sessionLoginBool = false //change back to false when i want sign in service
    var userID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //firebase reference created
        self.navigationItem.title = "Mikro Trainer"
        self.tabBarItem.title = "Home"
        
    }
    
    func endSession(){
        self.sessionLoginBool = false
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
        //function to make the user sign in if they havent signed in yet
        if sessionLoginBool == false {
            //set flag that workouts has started to deactivated
            UserDefaults.standard.set("0", forKey: flags.hasStartedFlag)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            tabBarController?.present(vc, animated: true, completion: nil)
            

        }else{
            //logic to get personal data
            //permission denied
            //get database reference
            ref = Database.database().reference()
            userID = String(Auth.auth().currentUser!.uid)
            print("ref is: \(ref)")
            print("user id is: \(userID)")
            
            self.getListOfPersonalData {
                print("done retrieving data")
            }
        }
        

        
        sessionLoginBool = true

    }

    @IBAction func goToMe(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PersonalInfoVC") as! PersonalInfoVC
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


//api call to get and parse personal data
func getListOfPersonalData(completion: @escaping ()->()){
    self.ref?.child("Users/\(userID)/PersonalData").observeSingleEvent(of: .value, with: { snapshot in
        //populate list with all personal values. if null return and dont fail
        //maybe use a dictionary?
        print(snapshot.value)
//        if let dict = snapshot.value as? [NSObject] {
//            for y in (dict) {
//                let obj = y as? NSDictionary
//                if let exerciseID = obj?["ExerciseID"] as? String {
//                    self.allExerciseIDList.append(exerciseID)
//                }
//                if let exerciseName = obj?["Name"] as? String {
//                    self.allExerciseNameList.append(exerciseName)
//                }
//            }
//            print("Personal data has been collected")
//                completion()
//        }else{
//            print("Failed to get personal data")
//                completion()
//        }
    })
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

