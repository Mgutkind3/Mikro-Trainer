//
//  MyWorkoutsVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 6/10/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MyWorkoutsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var MyWorkoutsTableView: UITableView!
    var myPreviousWorkouts = [String]()
    
    //list order corresponds with dates
    var prevWorkoutsNames = [String]()
    var prevWorkoutsDates = [String]()
    
    var workoutNameToAdd = String()
    var ref: DatabaseReference?
    var userID = String()
    var day = String()
    var month = String()
    var year = String()
    //0 means its coming from personal, 1 means its coming from groups
    var groupFlag = 0
    var groupID = String()
    
    var vcTitle = "Workouts"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = vcTitle
        let date = Date()
        let calendar = Calendar.current
        self.day = String(calendar.component(.day, from: date))
        self.month = String(calendar.component(.month, from: date))
        self.year = String(calendar.component(.year, from: date))
        
        //set user id and database reference
        self.userID = String(Auth.auth().currentUser!.uid)
        ref = Database.database().reference()
    }
    
    //reload table view everytime its seen
    override func viewWillAppear(_ animated: Bool) {
        self.myPreviousWorkouts.removeAll()
        self.prevWorkoutsDates.removeAll()
        self.prevWorkoutsNames.removeAll()
        
        //always be the first or last item in the array
        self.myPreviousWorkouts.append("Select the '+' sign to create a new workout")
        self.prevWorkoutsNames.append("Select the '+' sign to create a new workout")
        
        if self.groupFlag == 0{
        //get list of all workouts
            self.getAllMyWorkouts(userID: self.userID, ref: self.ref! ) { list in
                //run function to only get names and not the dates
                self.myPreviousWorkouts = list
                self.seperateDatesNames(prevWorkoutsList: self.myPreviousWorkouts)
                self.MyWorkoutsTableView.reloadData()
        }
        }else{
            //logic for coming from groups
//            print("Coming from the groups")
            self.getAllMyGroupWorkouts(userID: self.userID, ref: self.ref!, groupID: self.groupID) { list in
                self.myPreviousWorkouts = list
                self.seperateDatesNames(prevWorkoutsList: self.myPreviousWorkouts)
                self.MyWorkoutsTableView.reloadData()
            }
        }
    }
    
    //if it is not the first item, let it be deleteable
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row != 0 {
            return .delete
        }
        return .none
    }
    //delete workout
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            if self.groupFlag == 0{
                self.ref?.child("Users").child(self.userID).child("MyWorkouts").child(self.myPreviousWorkouts[indexPath.row]).setValue(nil)
            }else{
            self.ref?.child("Groups").child(self.groupID).child("GroupWorkouts").child(self.myPreviousWorkouts[indexPath.row]).setValue(nil)
            }
            self.myPreviousWorkouts.remove(at: indexPath.row)
            self.prevWorkoutsNames.remove(at: indexPath.row)
            self.MyWorkoutsTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myPreviousWorkouts.count
    }
    
    //set up the cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myPrevWorkCell = self.MyWorkoutsTableView.dequeueReusableCell(withIdentifier: "MyPrevWorkCell", for: indexPath) as! MyPreviousWorkoutsCell
        
        //customize each cell
        myPrevWorkCell.MyPrevWorkoutCellLabel.text = prevWorkoutsNames[indexPath.row]
        
        //Make the "instructions" cell standout by highlighting it gray
        if indexPath.row == 0 {
            myPrevWorkCell.MyPrevWorkoutCellLabel.textColor = UIColor.gray
            myPrevWorkCell.MyPrevWorkoutCellLabel.textAlignment = .center
            myPrevWorkCell.accessoryType = UITableViewCell.AccessoryType.none
            myPrevWorkCell.selectionStyle = .none
            myPrevWorkCell.isUserInteractionEnabled = false

        }else{
            myPrevWorkCell.MyPrevWorkoutCellLabel.textColor = UIColor.black
            myPrevWorkCell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }
        return myPrevWorkCell
    }
    
    //go to specific workout page
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            //do nothing
        }else{
            //go to workout exercises page
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "WorkoutExercisesVC") as! WorkoutExercisesVC
            vc.workoutFullName = myPreviousWorkouts[indexPath.row]
            vc.workoutTitle = self.prevWorkoutsNames[indexPath.row]
            vc.myPrevWorkouts = self.myPreviousWorkouts
            if self.groupFlag == 0{
                vc.groupFlag = 0
            }else{
                vc.groupID = self.groupID
                vc.groupFlag = self.groupFlag
            }
            self.navigationController?.pushViewController(vc, animated: true)

        }
    }
    
    //button to create a new workout
    @IBAction func addNewWorkoutButton(_ sender: Any) {
            let nameController = UIAlertController(title: "Workout Name?", message: "Please Name Your Workout:", preferredStyle: .alert)
        
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
                if let field = nameController.textFields?[0]  {
        
                    //if the user doesnt enter any name request a new name
                    if field.text! == "" || self.myPreviousWorkouts.contains("\(self.month)-\(self.day)-\(self.year): \(field.text!)") {
                        //put logic to make sure names do not repeat in here
                        nameController.message = "Please use a valid name"
                        self.present(nameController, animated: true, completion: nil)
                    }else{
                        self.workoutNameToAdd = field.text!
                        //create new workout in MyWorkouts
                        let workoutTitleFull = "\(self.month)-\(self.day)-\(self.year): \(self.workoutNameToAdd)" //create workout name
                        
                        if self.groupFlag == 0{
                            self.ref?.child("Users").child(self.userID).child("MyWorkouts").child(workoutTitleFull).setValue("")
                        }else{
                            //group logic
                            self.ref?.child("Groups").child(self.groupID).child("GroupWorkouts").child(workoutTitleFull).setValue("")
                        }
        
                        print("count: \(self.myPreviousWorkouts.count)")
                        //go to all exercises page
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "AllExercisesVC") as! AllExercisesVC
                        vc.flag = 0
                        if self.groupFlag == 0{
                            //individual
                            vc.groupFlag = 0
                        }else{
                            //group
                            vc.groupFlag = 1
                            vc.groupID = self.groupID
                        }
                        vc.workoutName = workoutTitleFull //pass data between view controllers
                        self.navigationController?.pushViewController(vc, animated: true)
        
                    }
            } else {
                print("IT BROKE!")
                // user did not fill field
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            nameController.addTextField { (textField) in
            textField.placeholder = "Name"
            }
            nameController.addAction(confirmAction)
            nameController.addAction(cancelAction)
            self.present(nameController, animated: true, completion: nil)
    }
    
    //function to split days from names
    func seperateDatesNames(prevWorkoutsList: [String]){
        for x in prevWorkoutsList{
            if x.contains(":"){
                let splitItems = x.split(separator: ":", maxSplits: 1)
                print(splitItems)
                self.prevWorkoutsNames.append(String(splitItems[1]))
                self.prevWorkoutsDates.append(String(splitItems[0]))
//            print("full name arr: \(fullNameArr)")
            }else{
                print("doesnt have : ")
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
