//
//  AllExercisesVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 5/17/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

//search for exercises
//https://www.raywenderlich.com/472-uisearchcontroller-tutorial-getting-started

//delegate for myWorkoutExercisesVC
protocol WorkoutNamesDelegate{
    func setNewName(name: String, fullName: String)
}

class AllExercisesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var ref: DatabaseReference?

    var myExerciseIDList = [String]()    //location 0
    var myExerciseNameList = [String]()
    var originalMyExNameList = [String]() //constant list used to see if exercise was previously in this list
    
    var myExercises = [String: String]() //impliment a dictionary for better performance later?

    var allExerciseIDList = [String]()    //location 1
    var allExerciseNameList = [String]()

    var thisWorkoutIDList = [String]()    //location 2
    var thisWorkoutNameList = [String]()  //exercises

    var currentNameList = [String]()    //whatever current list is
    var currentIDList = [String]()
    
    var myPrevWorkouts = [String]() //list of previous workouts
    
    var day = String()
    var month = String()
    var year = String()
    var userID = String()
    var exerciseIDToAdd = String()
    var exerciseNameToAdd = String()
    var workoutName = String()
    var delegate:WorkoutNamesDelegate? //delegate to return data to MyWorkoutExercisesVC
    var flag = Int()//0 is create new. 1 is editing current
    @IBOutlet weak var allExercisesTableView: UITableView!
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    //tells the table how many rows we need
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (currentNameList.count)
    }
    
    //tells the prototype cell what it functions like
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.allExercisesTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AllExercisesTableViewCell
        
        if self.segmentController.selectedSegmentIndex == 2 {
            cell.addExerciseButton.isEnabled = false
        }else{
            //gets rid of bug that sets all buttons to hidden
            cell.addExerciseButton.isEnabled = true
        }
        //customize each specific cell
        cell.cellHeaderLabel.text = currentNameList[indexPath.row]
        
        //tag selected cell with index "sender.tag"
        cell.addExerciseButton.tag = indexPath.row
        cell.addExerciseButton.addTarget(self, action: #selector(self.addSelectedExercise), for: .touchUpInside)
        
        return cell
    }
    
    //returns the row that was selected and reacts somehow
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsVC
        vc.exerciseTitle = self.currentNameList[indexPath.row]
        vc.exerciseID = self.currentIDList[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //dont let seg control sections 0 and 1 delete cells
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if self.segmentController.selectedSegmentIndex == 2 {
            return .delete
        }
        return .none
    }
    
    //delete an exercise from my list
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            print("Delete row: \(thisWorkoutNameList[indexPath.row])")
            print("id number: \(thisWorkoutIDList[indexPath.row])")
            
            //always add it back to list of all available exercises
            allExerciseNameList.append(thisWorkoutNameList[indexPath.row] ) //upon removal, add back to original lists
            allExerciseIDList.append(thisWorkoutIDList[indexPath.row])
            
            //logic to see if this exercise was previously in "my exercise 'past'" list
            if self.originalMyExNameList.contains(thisWorkoutNameList[indexPath.row]){
                print("add it back to my list")
                myExerciseNameList.append(thisWorkoutNameList[indexPath.row])
                myExerciseIDList.append(thisWorkoutIDList[indexPath.row])
            }

            //remove my exercise from firebase data
            self.ref?.child("Users").child(self.userID).child("MyWorkouts").child(workoutName).child("Exercise \(thisWorkoutIDList[indexPath.row])").setValue(nil)

            //remove name and id from current list lists
            self.thisWorkoutNameList.remove(at: indexPath.row)
            self.thisWorkoutIDList.remove(at: indexPath.row)
            
            //refresh table data according to lists
            self.currentIDList = self.thisWorkoutIDList
            self.currentNameList = self.thisWorkoutNameList
            self.allExercisesTableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //initially makethe right bar button nothing for location 0
        self.navigationItem.rightBarButtonItem = nil
        
        //set up database credentials
        setUserID()
        let date = Date()
        let calendar = Calendar.current
        self.day = String(calendar.component(.day, from: date))
        self.month = String(calendar.component(.month, from: date))
        self.year = String(calendar.component(.year, from: date))
        
        if self.flag == 1{
            self.title = "Editing"
        }else{
            self.title = "New Workout"
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //clear all values within all lists
        self.myExerciseIDList.removeAll()
        self.myExerciseNameList.removeAll()
        self.allExerciseNameList.removeAll()
        self.allExerciseIDList.removeAll()
        
        //function to get all exercises that also gets past exercises done before
        getListOfExercises {
            
            //constant list of names. dont change.
            self.originalMyExNameList = self.myExerciseNameList
            
            //signify which mode this page is in
            if self.flag == 1 {
                //modifying workout mode
                
                let oldWorkoutName = self.workoutName
                let nameAlert = UIAlertController(title: "New Name", message: "Please create a name for your edited workout", preferredStyle: UIAlertController.Style.alert)
                
                let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
                    if let field = nameAlert.textFields?[0]  {
                        
                        let newName = "\(self.month)-\(self.day)-\(self.year): \(field.text!)"
                        //if the user doesnt enter any name request a new name
                        if field.text! == "" || newName == oldWorkoutName || self.myPrevWorkouts.contains(newName) {
                            
                            nameAlert.message = "Please use a valid name"
                            self.present(nameAlert, animated: true, completion: nil)
                        }else{
                            let workoutNameDescr = field.text!
                            //create new workout in MyWorkouts
                            self.workoutName = "\(self.month)-\(self.day)-\(self.year): \(workoutNameDescr)" //create workout name
                            self.title = workoutNameDescr
                            
                            //use delegate to set previouse view controller title as well
                            self.delegate?.setNewName(name: workoutNameDescr, fullName: self.workoutName)
                            
                            //set up new workout with old info
                            for x in self.thisWorkoutIDList{
                                //add all the previous exercises from base workout to this new workout
                                self.addExerciseToMyWorkout(completion: {
                                    self.allExercisesTableView.reloadData()
                                    print("done creating new list")
                                }, exIDAdd: x)
                            }
                        }
                    } else {
                        print("IT BROKE!")
                        //should never get to this
                        // user did not fill field
                    }
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                    nameAlert.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                }
                nameAlert.addTextField { (textField) in
                    textField.placeholder = oldWorkoutName
                }
                
                nameAlert.addAction(confirmAction)
                nameAlert.addAction(cancelAction)
                self.present(nameAlert, animated: true, completion: nil)
                
                //make sure this is now the continuation of a current workout build
                self.flag = 0
            }else{
                //creating workout from scratch
            }
            
            //remove existing exercises from other lists so they cannot be reselected
            for y in self.thisWorkoutIDList{
                self.removeExerciseFromOtherLists(exerciseToRemove: y)
            }
            
            let location = self.segmentController.selectedSegmentIndex
            if location == 0{
                self.currentNameList = self.myExerciseNameList
                self.currentIDList = self.myExerciseIDList
                self.allExercisesTableView.reloadData()
            }
            if location == 1{
                self.currentNameList = self.allExerciseNameList
                self.currentIDList = self.allExerciseIDList
                self.allExercisesTableView.reloadData()
            }
            if location == 2{
                self.currentNameList = self.thisWorkoutNameList
                self.currentIDList = self.thisWorkoutIDList
                self.allExercisesTableView.reloadData()
            }
            
        }
    }
    
    //done editing current workout
    @IBAction func doneEditingButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //direct to create new exercise page
    @objc func createNewExerciseButton(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddExcerciseVC") as! AddExcerciseVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //segment controller changed
    @IBAction func segmentControlValueChangeButton(_ sender: Any) {
        let location = self.segmentController.selectedSegmentIndex
        
        if location == 0 {
            self.currentNameList = self.myExerciseNameList
            self.currentIDList = self.myExerciseIDList
            self.allExercisesTableView.reloadData()
            self.navigationItem.rightBarButtonItem = nil
        }
        if location == 1{
            self.currentNameList = self.allExerciseNameList
            self.currentIDList = self.allExerciseIDList
            self.allExercisesTableView.reloadData()
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewExerciseButton))
        }
        if location == 2 {
            self.currentNameList = self.thisWorkoutNameList
            self.currentIDList = self.thisWorkoutIDList
            self.allExercisesTableView.reloadData()
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneEditingButton(_:)))
            
        }
    }
    
    
    //set database reference and the user id so functions can be run from an outside class (myExerciseListVC)
    func setUserID() {
        self.userID = String(Auth.auth().currentUser!.uid)
        ref = Database.database().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //add exercise from all exercises to my exercises
    @objc func addSelectedExercise(sender: UIButton){
        self.exerciseIDToAdd = ""
        self.exerciseNameToAdd = ""

        //assign exercise ID to variable that is being queried based on segment location
        if self.segmentController.selectedSegmentIndex == 0{
            self.exerciseNameToAdd = self.myExerciseNameList[sender.tag]
            self.exerciseIDToAdd = self.myExerciseIDList[sender.tag]
        }
        if self.segmentController.selectedSegmentIndex == 1{
            self.exerciseNameToAdd = self.allExerciseNameList[sender.tag]
            self.exerciseIDToAdd = self.allExerciseIDList[sender.tag]
        }
        
        let addAlert = UIAlertController(title: "Add New Exercise", message: "Would you like to add \(self.exerciseNameToAdd) to your exercise list?", preferredStyle: UIAlertController.Style.alert)

        addAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in

            //delete added item from table views so you cannot add it again
            var i = 0
            if self.segmentController.selectedSegmentIndex == 0{
                //remove name and id from other lists
                self.myExerciseNameList.remove(at: sender.tag)
                self.myExerciseIDList.remove(at: sender.tag)
                
                //set table data and reload table
                self.currentNameList = self.myExerciseNameList
                self.currentIDList = self.myExerciseIDList
                
                //find the exercise in the other list and remove it
                for x in self.allExerciseIDList {
                    if x == self.exerciseIDToAdd{
                        self.allExerciseIDList.remove(at: i)
                        self.allExerciseNameList.remove(at: i)
                    }
                    i = i + 1
                }
            }
            
            var q = 0
            if self.segmentController.selectedSegmentIndex == 1{
                //remove name and id from other lists
                self.allExerciseIDList.remove(at: sender.tag)
                self.allExerciseNameList.remove(at: sender.tag)
                
                //set table data and reload data
                self.currentNameList = self.allExerciseNameList
                self.currentIDList = self.myExerciseIDList
                
                //find the exercise in the other list and remove it
                for x in self.myExerciseIDList {
                    if x == self.exerciseIDToAdd{
                        self.myExerciseIDList.remove(at: q)
                        self.myExerciseNameList.remove(at: q)
                    }
                    q = q + 1
                }
            }
            
            self.thisWorkoutIDList.append(self.exerciseIDToAdd)
            self.thisWorkoutNameList.append(self.exerciseNameToAdd)
            
            //add exercises to the database
            self.allExercisesTableView.reloadData()
            self.addExerciseToMyWorkout(completion: {
                print("exercise added to my exercise")
                addAlert.dismiss(animated: true, completion: nil)
                
                //reload table to refresh all the data
                self.allExercisesTableView.reloadData()
            }, exIDAdd: self.exerciseIDToAdd)
        }))

        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            addAlert.dismiss(animated: true, completion: nil)
        }))

        present(addAlert, animated: true, completion: nil)
    }
    
    //function to add exercises to MyWorkouts list in Firebase
    func addExerciseToMyWorkout(completion: @escaping ()->(), exIDAdd: String){
        self.ref?.child("Exercises/\(exIDAdd)").observeSingleEvent(of: .value, with: { snapshot in
            //get data from exercises branch and put it in my exercises branch
            var w = self.workoutName
            var g = ""
            var n = ""
            var e = ""
            var i = 0

            if let dict = snapshot.value as? NSDictionary {
                if let muscleGroup = dict["MuscleGroup"] as? String {
                    g = muscleGroup
                }
                if let name = dict["Name"] as? String {
                    n = name
                }
                if let exerciseID = dict["ExerciseID"] as? String {
                    e = exerciseID
                }
                
                let workoutDetails = [n, g, e, w ]
                let workoutFields = ["Name", "MuscleGroup", "ExerciseID", "WorkoutName" ]
                
                //add exercise to workout with minimal metadata
               for x in workoutFields {
                self.ref?.child("Users").child(self.userID).child("MyWorkouts").child(self.workoutName).child("Exercise \(e)").child(x).setValue(workoutDetails[i])
                i = i + 1
                }
                
                //complete if exercise was added successfully
                print("exercise added successfully")
                completion()
            }else{
                print("exercise not successfully added")
                //return if error in retrieving exercise
                completion()
            }
        })
    }
    

}
