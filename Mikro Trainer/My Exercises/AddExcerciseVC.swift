//
//  AddExcerciseVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 5/16/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class AddExcerciseVC: UIViewController {
    @IBOutlet weak var excerciseNameTxtField: UITextField!
    @IBOutlet weak var muscGrpTxtField: UITextField!
    @IBOutlet weak var wtTxtField: UITextField!
    @IBOutlet weak var setTxtField: UITextField!
    @IBOutlet weak var repsTxtField: UITextField!
    @IBOutlet weak var addExcerciseErrorLabel: UILabel!
    var ref: DatabaseReference?
    var userID = String()
    var exName = String()
    var mGrp = String()
    var wt = String()
    var sets = String()
    var reps = String()
    var exID = String()
    var highestID = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        userID = String(Auth.auth().currentUser!.uid)
        exID = String(exerciseNumber())

    }
    
    @IBAction func addExcerciseButton(_ sender: Any) {
        addExcerciseErrorLabel.text = ""
        
        exName = excerciseNameTxtField.text!
        mGrp = muscGrpTxtField.text!
        wt = wtTxtField.text!
        sets = setTxtField.text!
        reps = repsTxtField.text!
        
        var i = 0//counter to make sure arrays mirror
        
        //call exercise branch and see what number of exercises we are at FIX CLOSURE PROBLEM
        
        //make sure all fields are filled in
        if exName == "" || mGrp == "" || wt == "" || sets == "" || reps == "" {
            addExcerciseErrorLabel.text = "Please fill in all the fields"
            return
        }
        
        let workoutDetails = [exName, mGrp, wt, sets, reps, exID ]
        let workoutFields = ["Name", "MuscleGroup","BaseWeight", "BaseSets", "BaseReps", "ExerciseID" ]
        for x in workoutFields {
            //print(workoutDetails[i]!)
            ref?.child("Exercises").child(exID).child(x).setValue(workoutDetails[i])
//            ref?.child("Users").child(self.userID).child("MyExercises").child("Exercise  Number:").setValue("1")//make the last value dynamic so it changes with every number
            i = i + 1
        }
        
    }
    
    //find the highest exercise number recorded in the database
    func exerciseNumber()-> Int{
        
        //get the highest exercise number and add 1 to it
            self.ref?.child("Exercises").observeSingleEvent(of: .value, with: { snapshot in
            //populate notes from previous
            let dict = snapshot.value as? [NSObject]
            for y in (dict)! {
                let obj = y as? NSDictionary
                if let exerciseID = obj?["ExerciseID"] as? String {
                    print("ex: ")
                    print(exerciseID)
                    let exerciseIDInt = Int(exerciseID)
                    // find the highest user id (if there are any) and create a new exercise id
                    if exerciseIDInt! >= self.highestID{
                        self.highestID = exerciseIDInt! + 1
//                        print("bigger: \(self.highestID)")
                    }
                }
            }
                
        })
        print("highestID returned: \(highestID)")
        return highestID
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
