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
    var personalDict = [String: String]()
    var masterDateList = [String]()
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var lastWorkoutLabel: UILabel!
    
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
            ref = Database.database().reference()
            userID = String(Auth.auth().currentUser!.uid)
            
            //call api to get the user's personal data
            self.getListOfPersonalData {
                //set welcome label
                self.welcomeLabel.text = "Welcome, \(self.personalDict["UserName"]!)"
            }
            //get the date of the last workout
            self.getLastWorkoutDate {
                print("done getting last workout")
            }
        }
        
        sessionLoginBool = true
    }

    @IBAction func goToMe(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PersonalInfoVC") as! PersonalInfoVC
        vc.delegate = self
        vc.personalDict = self.personalDict
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
        if let dict = snapshot.value as? NSDictionary {
            self.personalDict = dict as! [String : String]
            print("Personal data has been collected")
                completion()
        }else{
            print("Failed to get personal data")
                completion()
        }
    })
}
    
func getLastWorkoutDate(completion: @escaping ()->()){
    self.ref?.child("Users/\(userID)/HistoricalExercises").observeSingleEvent(of: .value, with: { snapshot in
            //populate list with all personal values. if null return and dont fail
        if let dict = snapshot.value as? NSDictionary {
            for x in dict{
                if let dateList = x.value as? NSDictionary{
                    if let dateIn = dateList.allKeys as? [String]{
                        self.masterDateList.append(contentsOf: dateIn)
                    }
                }
            }
//            print(self.masterDateList)
            self.lastWorkoutLabel.text = self.calculateLastWorkoutDate(datesList: self.masterDateList)
            completion()
        }else{
            print("Failed to get personal data")
            completion()
            }
        })
    }
    
    //compare dates to get the most recent one
    func calculateLastWorkoutDate(datesList: [String])->String{
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MM-dd-yyyy:HH:mm:ss"
        var mostRecentDate = dateFormatterGet.date(from: "01-01-1900:01:01:01")
        
        //go through array and compare dates, keeping the most recent one
        for x in datesList{
            if let date = dateFormatterGet.date(from: x) {
//                print(date)
                if (date > mostRecentDate!){
                    mostRecentDate = date
                }
            } else {
                print("There was an error decoding the string")
            }
        }
        //reformat latest date and return it
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MM/dd/yyyy"
        var solution = dateFormatterPrint.string(from: mostRecentDate!)
        //incase there are no workouts logged
        if(solution == "01/01/1900"){
            solution = "No Prior Workouts Logged"
        }
        return(solution)
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

