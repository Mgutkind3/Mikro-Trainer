//
//  WorkoutExercisesVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 6/24/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class WorkoutExercisesVC: UIViewController ,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var workoutExercisesTableView: UITableView!
    var workoutTitle = ""
    var ref: DatabaseReference?
    var userID = String()
    var workoutExerciseNames = [String]()
    var workoutExerciseIDs = [String]() //for references (order matters)
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutExerciseNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wExCell = self.workoutExercisesTableView.dequeueReusableCell(withIdentifier: "wECell", for: indexPath) as! WorkoutExercisesCell
        
        wExCell.wExCellLabel.text = workoutExerciseNames[indexPath.row]
        
        return wExCell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = workoutTitle
        
        //set user id and database reference
        self.userID = String(Auth.auth().currentUser!.uid)
        ref = Database.database().reference()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = self.workoutTitle
        workoutExerciseNames.removeAll()
        workoutExerciseIDs.removeAll()
        //get list of workouts that are specifically in that workout
        getMyWorkoutExercises(completion: {
            self.workoutExercisesTableView.reloadData()
        }, workoutName: workoutTitle)
    }

    //edit the current workout you are have selected
    @IBAction func editThisWorkoutList(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AllExercisesVC") as! AllExercisesVC
        vc.flag = 1 //editing current workout
        vc.thisWorkoutIDList = self.workoutExerciseIDs
        vc.thisWorkoutNameList = self.workoutExerciseNames
        vc.workoutName = self.workoutTitle
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
