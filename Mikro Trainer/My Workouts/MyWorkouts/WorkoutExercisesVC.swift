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


class WorkoutExercisesVC: UIViewController ,UITableViewDelegate, UITableViewDataSource, WorkoutNamesDelegate {

    
    @IBOutlet weak var workoutExercisesTableView: UITableView!
    var workoutTitle = ""
    var workoutFullName = ""
    var ref: DatabaseReference?
    var userID = String()
    var workoutExerciseNames = [String]()
    var workoutExerciseIDs = [String]() //for references (order matters)
    var myPrevWorkouts = [String]()
    
    @IBOutlet weak var startStopBtn: UIButton!
    var startStopFlag = 0 //0 it should be stopped, 1 it should be in progress
    @IBOutlet weak var rebuildBtnOutlet: UIBarButtonItem!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutExerciseNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wExCell = self.workoutExercisesTableView.dequeueReusableCell(withIdentifier: "wECell", for: indexPath) as! WorkoutExercisesCell
        
        wExCell.wExCellLabel.text = workoutExerciseNames[indexPath.row]
        if startStopFlag == 0 {
            //cant select workout without starting workout
            wExCell.selectionStyle = .default
            wExCell.isUserInteractionEnabled = true
            wExCell.accessoryType = UITableViewCell.AccessoryType.detailButton
        }else{
            //can select exercise once workout has begun
            wExCell.selectionStyle = .default
            wExCell.isUserInteractionEnabled = true
            wExCell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            //logic to check the exercise that has been completed
            
        }
        
        return wExCell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = workoutTitle
        
        //set user id and database reference
        self.userID = String(Auth.auth().currentUser!.uid)
        ref = Database.database().reference()
        
    }
    
    //called by the delegate in 'allExercisesVC' to get new rebuilt name
    func setNewName(name: String, fullName: String) {
        self.workoutTitle = name
        self.title = name
        self.workoutFullName = fullName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        workoutExerciseNames.removeAll()
        workoutExerciseIDs.removeAll()
        self.title = self.workoutTitle
//        self.workoutFullName = //new workout title
        
        //get list of workouts that are specifically in that workout
        getMyWorkoutExercises(completion: {
            self.workoutExercisesTableView.reloadData()
        }, workoutName: workoutFullName)
    }
    
    //go to specific workout after an exercise has begun
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = self.workoutExercisesTableView.cellForRow(at: indexPath) as! WorkoutExercisesCell
        if cell.accessoryType == .disclosureIndicator {
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CurrentExerciseVC") as! CurrentExerciseVC
            vc.exerciseTitle = self.workoutExerciseNames[indexPath.row]
            vc.exerciseID = self.workoutExerciseIDs[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsVC
            vc.exerciseTitle = workoutExerciseNames[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    
    //begin/end workout
    @IBAction func startWorkoutButton(_ sender: Any) {
        if startStopFlag == 0{
            //start logic
            startStopBtn.backgroundColor = UIColor.red
            startStopBtn.setTitle("Stop", for: .normal)
            startStopFlag = 1
            self.rebuildBtnOutlet.isEnabled = false
            self.workoutExercisesTableView.reloadData()
            self.navigationItem.hidesBackButton = true
            
        }else{
            //stop logic
            //double check to make sure user wants to end workout
            let stopWarn = UIAlertController(title: "End Workout", message: "Are you sure you want to finish your workout?", preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
                self.startStopBtn.backgroundColor = UIColor.green
                self.startStopBtn.setTitle("Start", for: .normal)
                self.startStopFlag = 0
                self.rebuildBtnOutlet.isEnabled = true
                self.workoutExercisesTableView.reloadData()
                self.navigationItem.hidesBackButton = false
                //set flag that workouts has started to deactivated
                UserDefaults.standard.set("0", forKey: flags.hasStartedFlag)
                UserDefaults.standard.set("", forKey: flags.uniqueID)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                print("cancel!")
            }
            stopWarn.addAction(confirmAction)
            stopWarn.addAction(cancelAction)
            self.present(stopWarn, animated: true, completion: nil)
            
        }
    }
    

    //edit the current workout you are have selected "modify"
    @IBAction func editThisWorkoutList(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AllExercisesVC") as! AllExercisesVC
        vc.delegate = self
        vc.flag = 1 //editing current workout
        vc.thisWorkoutIDList = self.workoutExerciseIDs
        vc.thisWorkoutNameList = self.workoutExerciseNames
        vc.workoutName = self.workoutTitle
        vc.myPrevWorkouts = self.myPrevWorkouts
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}//class
