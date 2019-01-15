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
import HealthKit

class MainMenu: UIViewController, SignOutMethod {
    
    //https://resizeappicon.com/ great resource for app sizes
    var ref: DatabaseReference?
    var sessionLoginBool = false //change back to false when i want sign in service
    var userID = String()
    var personalDict = [String: String]()
    var masterDateList = [String]()
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var lastWorkoutLabel: UILabel!
    let healthStore = HKHealthStore()
    @IBOutlet weak var stepsLbl: UILabel!
    @IBOutlet weak var distanceTrvldLbl: UILabel!
    @IBOutlet weak var flightsClimbedLbl: UILabel!
    @IBOutlet weak var nextWorkoutLbl: UILabel!
    
    //quote of the day?
    //http://quotes.rest/qod.json?category=inspire
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //firebase reference created
        self.navigationItem.title = "Mikro Trainer"
        self.tabBarItem.title = "Home"
 
        //get health kit access
        self.healthKitSetup()
        
    }
    //logout functionality
    func endSession(){
        self.sessionLoginBool = false
        self.masterDateList.removeAll()
    }
    
    //https://stackoverflow.com/questions/36559581/healthkit-swift-getting-todays-steps
    //function to authenticate and use health kit
    func healthKitSetup(){
        //step 1- check to see if health kit is available on device
        if HKHealthStore.isHealthDataAvailable(){
            print("We can use health kit! :)")
            
            
            let allTypes = Set([HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
                               HKObjectType.quantityType(forIdentifier: .stepCount)!])
            
            healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                if !success {
                    // Handle the error here.
                    print("We have an error: ", error as Any)
                }else{
                    print("authorization gained")
                    //get amount of steps taken today
                    self.getTodaysSteps(completion: { (steps) in
//                        print("steps: ", steps)
                        self.stepsLbl.text = "Steps Today: \(Int(steps)) Steps"
                    })
                    
                    //get amount of distance traveled today
                    self.getTodaysDistance(completion: { (dist) in
//                        print("distance traveled: \(dist)")
                        self.distanceTrvldLbl.text = "Distance Traveled Today: \(dist.rounded(toPlaces: 2)) Miles"
                    })
                    
                    //get the amount of flights climbed
                    self.getTodaysFloors(completion: { (floors) in
//                        print("floors climbed: \(floors)")
                        self.flightsClimbedLbl.text = "Flights Climbed Today: \(Int(floors)) Floors"
                    })
                }
            }
        }else{
            print("we cant use health kit :(")
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        print("MainMenu")
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
            
            self.getNextWorkouts { nextWorkout, workoutName  in
                print("done getting next workouts")
                self.nextWorkoutLbl.text = "\(workoutName) on \(nextWorkout)"
            }
            
            //get health kit access
            self.healthKitSetup()
        }
        
        sessionLoginBool = true
    }

    //go to personal profile
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
    
//function to retrieve last workout from historical exercises. Will fail if not populated
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
            self.lastWorkoutLabel.text = self.calculateLastWorkoutDate(datesList: self.masterDateList)
            completion()
        }else{
            print("Failed to get personal data")
            self.lastWorkoutLabel.text = "No Prior Workouts available"
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
        let solution = dateFormatterPrint.string(from: mostRecentDate!)
        //incase there are no workouts logged
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

