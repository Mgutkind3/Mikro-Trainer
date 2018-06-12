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

class AllExercisesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var ref: DatabaseReference?

    var myExerciseIDList = [String]()    //location 0
    var myExerciseNameList = [String]()

    var allExerciseIDList = [String]()    //location 1
    var allExerciseNameList = [String]()

    var thisWorkoutIDList = [String]()    //location 2
    var thisWorkoutNameList = [String]()

    var currentNameList = [String]()    //whatever current list is
    
    var userID = String()
    var exerciseIDToAdd = String()
    var exerciseNameToAdd = String()
    var workoutName = String()
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
            cell.addExerciseButton.isHidden = true
        }
        //customize each specific cell
        cell.cellHeaderLabel.text = currentNameList[indexPath.row]
        
        //tag selected cell with index
        cell.addExerciseButton.tag = indexPath.row
        cell.addExerciseButton.addTarget(self, action: #selector(self.addSelectedExercise), for: .touchUpInside)
        
        return cell
    }
    
    //returns the row that was selected and reacts somehow
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print("workout name: \(self.workoutName)")
        //set up database credentials
        setUserID()
        
        //function to get all exercises
        getListOfExercises {
            //logic to make one final list without already included exercises goes here.
            print("modifying list of workouts to add...")
            
//            //create a list of exercises i already have
//            for x in self.myExerciseIDList {
//                if self.allExerciseIDList.contains(x){
//                    //only display exercises that are not currently in MyExercises
//                    let q = self.allExerciseIDList.index(of: x)!
//                    self.allExerciseIDList.remove(at: q)
//                    self.allExerciseName.remove(at: q)
//                }
//            }
            
            //reload table to refresh all the data
            self.currentNameList = self.myExerciseNameList
            self.allExercisesTableView.reloadData()
        }
    }
    
    @IBAction func segmentControlValueChangeButton(_ sender: Any) {
        let location = self.segmentController.selectedSegmentIndex
        
        if location == 0 {
            self.currentNameList = self.myExerciseNameList
            self.allExercisesTableView.reloadData()
        }
        if location == 1{
            self.currentNameList = self.allExerciseNameList
            self.allExercisesTableView.reloadData()
        }
        if location == 2 {
            self.currentNameList = self.thisWorkoutNameList
            self.allExercisesTableView.reloadData()
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
    
    //api call to get the list of ALL exercises
    func getListOfExercises(completion: @escaping ()->()){
        self.ref?.child("Exercises").observeSingleEvent(of: .value, with: { snapshot in
            //populate array with all exercise id's if value is not null. if null return and dont fail
            
            if let dict = snapshot.value as? [NSObject] {
                for y in (dict) {
                    let obj = y as? NSDictionary
                    if let exerciseID = obj?["ExerciseID"] as? String {
//                        print("exercise name: \(exerciseID)")
                        self.allExerciseIDList.append(exerciseID)
                    }
                    if let exerciseName = obj?["Name"] as? String {
//                        print("exercise name: \(exerciseName)")
                        self.allExerciseNameList.append(exerciseName)
                    }
                }
                //do not complete this function until my list of exercises is already found
                self.getMyList {
                    print("My List: Obtained")
                    completion()
                }

            }else{
                //do not complete this function until my list of exercises is already found
                //return cause the array was full of null values
                self.getMyList {
                    print("My List: Obtained")
                    completion()
                }

            }
            
        })
    }
    
    //fucntion to get the exercises in my list
    func getMyList(completion: @escaping ()->()){
        self.ref?.child("Users/\(self.userID)/MyExercises").observeSingleEvent(of: .value, with: { snapshot in
            //populate array with all my exercises if value is not null. if null return and dont fail
            
            if let dict = snapshot.value as? NSDictionary{
                for y in (dict) {

                    let obj = y.value as? NSDictionary
                    if let exerciseID = obj?["ExerciseID"] as? String {
//                        print("exercise name: \(exerciseID)")
                        self.myExerciseIDList.append(exerciseID)
                    }
                    if let exerciseName = obj?["Name"] as? String {
//                        print("exercise name: \(exerciseName)")
                        self.myExerciseNameList.append(exerciseName)
                    }
                }
                print("MyExercises list populated")
                completion()
            }else{
                //return cause the array was full of null values
                print("my array not populated cause no 'MyExercises' found")
                completion()
            }

        })
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
        
        let addAlert = UIAlertController(title: "Add New Exercise", message: "Would you like to add \(self.exerciseNameToAdd) to your exercise list?", preferredStyle: UIAlertControllerStyle.alert)

        addAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in

            //delete added item from table views so you cannot add it again
            var i = 0
            if self.segmentController.selectedSegmentIndex == 0{
                //remove name and id from other lists
                self.myExerciseNameList.remove(at: sender.tag)
                self.myExerciseIDList.remove(at: sender.tag)
                //test
                self.currentNameList = self.myExerciseNameList
                
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
                //test
                self.currentNameList = self.allExerciseNameList
                
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
                self.addExerciseToMyWorkout {
                    print("exercise added to my exercise")
                    addAlert.dismiss(animated: true, completion: nil)
   
                    //reload table to refresh all the data
                    self.allExercisesTableView.reloadData()
                }
        }))

        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            addAlert.dismiss(animated: true, completion: nil)
        }))

        present(addAlert, animated: true, completion: nil)
    }
    
    //function to add exercises to MyWorkouts list in Firebase
    func addExerciseToMyWorkout(completion: @escaping ()->()){
        self.ref?.child("Exercises/\(self.exerciseIDToAdd)").observeSingleEvent(of: .value, with: { snapshot in
            //get data from exercises branch and put it in my exercises branch
//            var r = ""
//            var s = ""
            var w = self.workoutName
            var g = ""
            var n = ""
            var e = ""
            var i = 0

            if let dict = snapshot.value as? NSDictionary {
//                if let baseReps = dict["BaseReps"] as? String {
//                    r = baseReps
//                }
//                if let baseSets = dict["BaseSets"] as? String {
//                    s = baseSets
//                }
//                if let baseWeight = dict["BaseWeight"] as? String {
//                    w = baseWeight
//                }
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
                
                //add exercise to workout wuth minimal metadata
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
