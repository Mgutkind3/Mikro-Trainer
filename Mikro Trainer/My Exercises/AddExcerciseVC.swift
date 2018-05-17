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
    var highestID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        ref = Database.database().reference()
        userID = String(Auth.auth().currentUser!.uid)

    }
    
    @IBAction func addExcerciseButton(_ sender: Any) {
        addExcerciseErrorLabel.text = ""
        addExcerciseErrorLabel.textColor = UIColor.red
        
        exName = excerciseNameTxtField.text!
        mGrp = muscGrpTxtField.text!
        wt = wtTxtField.text!
        sets = setTxtField.text!
        reps = repsTxtField.text!
        
        var i = 0//counter to make sure arrays mirror'
        
        //make sure all fields are filled in
        if exName == "" || mGrp == "" || wt == "" || sets == "" || reps == "" {
            addExcerciseErrorLabel.text = "Please fill in all the fields"
            return
        }
        
        //call exercise branch and see what number of exercises we are at completion must be completed before this contents is run
        exerciseNumber(completion: { () in
            print("highest id check: \(self.highestID)")
            self.exID = String(self.highestID)
            
            let workoutDetails = [self.exName, self.mGrp, self.wt, self.sets, self.reps, self.exID ]
            let workoutFields = ["Name", "MuscleGroup","BaseWeight", "BaseSets", "BaseReps", "ExerciseID" ]
            
            for x in workoutFields {
                self.ref?.child("Exercises").child(self.exID).child(x).setValue(workoutDetails[i])
            self.ref?.child("Users").child(self.userID).child("MyExercises").child("ExerciseNumber \(self.exID)").setValue(self.exID)//make the last value dynamic so it changes with every number
                i = i + 1
            }
        })
        
        //clear all text fields
        excerciseNameTxtField.text = ""
        muscGrpTxtField.text = ""
        wtTxtField.text = ""
        setTxtField.text = ""
        repsTxtField.text = ""
        addExcerciseErrorLabel.textColor = UIColor.green
        addExcerciseErrorLabel.text = "Success!"
        //self.navigationController?.popViewController(animated: true)//close current view controller

    }
    
    //find the highest exercise number recorded in the database
    func exerciseNumber(completion: @escaping ()->()){

        //get the highest exercise number and add 1 to it
            self.ref?.child("Exercises").observeSingleEvent(of: .value, with: { snapshot in
                //populate array with all exercise id's
                if let dict = snapshot.value as? [NSObject] {
                    for y in (dict) {
                let obj = y as? NSDictionary
                if let exerciseID = obj?["ExerciseID"] as? String {
//                    print("ex: ")
//                    print(exerciseID)
                    let exerciseIDInt = Int(exerciseID)
                    
                    // find the highest user id (if there are any) and create a new exercise id
                    if exerciseIDInt! >= self.highestID{
                        self.highestID = exerciseIDInt! + 1
                    }
                }
            }
                completion()
                }else{
                //if no exercises available start database at unique ID of 0
                self.highestID = 0
                completion()
                }
                
        })

//        return highestID

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
