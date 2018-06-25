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
        self.myPreviousWorkouts.append("Create New Workout")
        
        //get list of all workouts
        getAllMyWorkouts {
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
        
        //Make the "create new workout" cell standout by highlighting it green
        if myPreviousWorkouts[indexPath.row] == "Create New Workout" {
            myPrevWorkCell.MyPrevWorkoutCellLabel.textColor = UIColor.green
        }else{
            myPrevWorkCell.MyPrevWorkoutCellLabel.textColor = UIColor.black
        }
        return myPrevWorkCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if myPreviousWorkouts[indexPath.row] == "Create New Workout" {
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
        }else{
            //go to workout exercises page
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "WorkoutExercisesVC") as! WorkoutExercisesVC
            vc.workoutTitle = myPreviousWorkouts[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
