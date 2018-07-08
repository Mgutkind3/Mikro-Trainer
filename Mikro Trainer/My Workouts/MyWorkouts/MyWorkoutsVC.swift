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
    var workoutNameToAdd = String()
    var ref: DatabaseReference?
    var userID = String()
    var day = String()
    var month = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Workouts"
        let date = Date()
        let calendar = Calendar.current
        self.day = String(calendar.component(.day, from: date))
        self.month = String(calendar.component(.month, from: date))
        
        //set user id and database reference
        self.userID = String(Auth.auth().currentUser!.uid)
        ref = Database.database().reference()
    }
    
    //reload table view everytime its seen
    override func viewWillAppear(_ animated: Bool) {
        self.myPreviousWorkouts.removeAll()
        //always be the first or last item in the array
        self.myPreviousWorkouts.append("Select the '+' sign to create a new workout")
        
        //get list of all workouts
        getAllMyWorkouts {
            self.MyWorkoutsTableView.reloadData()
        }
    }
    
    //if it is not the first item, let it be deleteable
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row != 0 {
            return .delete
        }
        return .none
    }
    //delete workout
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            self.ref?.child("Users").child(self.userID).child("MyWorkouts").child(self.myPreviousWorkouts[indexPath.row]).setValue(nil)
            self.myPreviousWorkouts.remove(at: indexPath.row)
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
        myPrevWorkCell.MyPrevWorkoutCellLabel.text = myPreviousWorkouts[indexPath.row]
        
        //Make the "instructions" cell standout by highlighting it gray
        if indexPath.row == 0 {
            myPrevWorkCell.MyPrevWorkoutCellLabel.textColor = UIColor.gray
            myPrevWorkCell.MyPrevWorkoutCellLabel.textAlignment = .center
//            myPrevWorkCell.MyPrevWorkoutCellLabel.numberOfLines = 0
//            myPrevWorkCell.MyPrevWorkoutCellLabel.lineBreakMode = .byWordWrapping
            myPrevWorkCell.accessoryType = UITableViewCellAccessoryType.none
            myPrevWorkCell.selectionStyle = .none
            myPrevWorkCell.isUserInteractionEnabled = false

        }else{
            myPrevWorkCell.MyPrevWorkoutCellLabel.textColor = UIColor.black
            myPrevWorkCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }
        return myPrevWorkCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            //do nothing
        }else{
            //go to workout exercises page
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "WorkoutExercisesVC") as! WorkoutExercisesVC
            vc.workoutTitle = myPreviousWorkouts[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)

        }
    }
    
    //button to create a new workout
    @IBAction func addNewWorkoutButton(_ sender: Any) {
            let nameController = UIAlertController(title: "Workout Name?", message: "Please Name Your Workout:", preferredStyle: .alert)
        
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
                if let field = nameController.textFields?[0]  {
        
                    //if the user doesnt enter any name request a new name
                    if field.text! == "" {
                        //put logic to make sure names do not repeat in here
                        nameController.message = "Please use a valid name"
                        self.present(nameController, animated: true, completion: nil)
                    }else{
                        self.workoutNameToAdd = field.text!
                        //create new workout in MyWorkouts
                        let workoutTitleFull = "\(self.month)-\(self.day): \(self.workoutNameToAdd)" //create workout name
                        self.ref?.child("Users").child(self.userID).child("MyWorkouts").child(workoutTitleFull).setValue("")
        
                        //go to all exercises page
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "AllExercisesVC") as! AllExercisesVC
                        vc.flag = 0
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
