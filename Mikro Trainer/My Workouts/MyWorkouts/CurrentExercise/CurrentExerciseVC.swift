//
//  CurrentExerciseVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 7/7/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

//set flag in local storage
struct flags{
    static let hasStartedFlag = "0" //deactivated
    static let uniqueID = ""
}

class CurrentExerciseVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CellCheckDelegate {
    
    @IBOutlet weak var saveBtnOutlet: UIBarButtonItem!
    var exerciseTitle = ""
    var exerciseID = ""
    var exerciseSets = 0
    var exerciseReps = 0
    var saveBtnFlag = 0 //deactivated
    var deactivateTableFlag = 0 //deactivated
    var workoutName = ""
    var ref: DatabaseReference?
    var userID = String()
    var uniqueIDString = String()
    
    //lists to keep track of weights and reps
    var setsWeightDict: [String: String] = [:]
    var repsDict: [String: String] = [:]
    
    //calendar variables
    var second = String()
    var minute = String()
    var hour = String()
    var day = String()
    var month = String()
    var year = String()

    @IBOutlet weak var addSetBtnOutlet: UIButton!
    @IBOutlet weak var WipExCellTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.addSetBtnOutlet.isEnabled = false
        
        //set user id and database reference
        self.userID = String(Auth.auth().currentUser!.uid)
        ref = Database.database().reference()
        
        self.title = exerciseTitle
        print("exerciseID: \(exerciseID)")
        
        //get all of the information in regards to this exercise
        getMyExerciseData {
            self.WipExCellTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.exerciseSets
    }
    
    //set all rows to the height of 80
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    //if it is not the first item, let it be deleteable
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row != 0 {
            return .delete
        }
        return .none
    }
    
    //delete set
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            let cell: WIPExerciseCell = self.WipExCellTableView.cellForRow(at: indexPath) as! WIPExerciseCell
            self.exerciseSets = self.exerciseSets-1
            //delete the data if the set was deleted
            cell.repsTxtField.text = ""
            cell.setTxtField.text = ""
            self.WipExCellTableView.reloadData()
            self.repsDict[String(indexPath.row)] = ""
            self.setsWeightDict[String(indexPath.row)] = ""
            //delete from firebase eventually
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wipExCell = self.WipExCellTableView.dequeueReusableCell(withIdentifier: "WipExCell", for: indexPath) as! WIPExerciseCell
        
        wipExCell.setLabel.text = "Set \(indexPath.row+1)"
        wipExCell.errorLabel.text = ""
        wipExCell.errorLabel.textColor = UIColor.red
        wipExCell.delegate = self
        
        //activate or deactivate table based on Start
        if self.deactivateTableFlag == 0{
            self.WipExCellTableView.isUserInteractionEnabled = false
            wipExCell.setLabel.isEnabled = false
            wipExCell.repsTxtField.isEnabled = false
            wipExCell.setTxtField.isEnabled = false
        }else{
            self.WipExCellTableView.isUserInteractionEnabled = true
            wipExCell.setLabel.isEnabled = true
            wipExCell.repsTxtField.isEnabled = true
            wipExCell.setTxtField.isEnabled = true
        }
        return wipExCell
    }
    
    //save to historical workouts
    //now the "start" and "stop" buttons
    @IBAction func saveExerBtn(_ sender: Any) {
        
        if self.saveBtnOutlet.title == "Start"{
            print("start")
            self.navigationItem.hidesBackButton = true
            self.addSetBtnOutlet.isEnabled = true
            self.saveBtnOutlet.title = "Stop"
            //make the uitable view touchable
            self.deactivateTableFlag = 1
            self.WipExCellTableView.reloadData()
            
            //started workout flag set to
            if let continueFlag =  UserDefaults.standard.string(forKey: flags.hasStartedFlag){
                if continueFlag == "0"{
                    UserDefaults.standard.set("1", forKey: flags.hasStartedFlag)
                    print("set started string to: \(UserDefaults.standard.string(forKey: flags.hasStartedFlag) as Any)")
                    
//                    let uniqueID = Database.database().reference().childByAutoId()
                    //generate timestamp
                    let date = Date()
                    let calendar = Calendar.current
                    self.second = String(calendar.component(.second, from: date))
                    self.minute = String(calendar.component(.minute, from: date))
                    self.hour = String(calendar.component(.hour, from: date))
                    self.day = String(calendar.component(.day, from: date))
                    self.month = String(calendar.component(.month, from: date))
                    self.year = String(calendar.component(.year, from: date))
                    
                    let timestamp = "\(month)-\(day)-\(year):\(hour):\(minute):\(second)"
                    UserDefaults.standard.set(timestamp, forKey: flags.uniqueID)
                    self.uniqueIDString = timestamp
                    print("unique id: \(self.uniqueIDString)")
                }else{
                    //continuing workout
                    print("continue flag: \(continueFlag)")
                    print("unique string: \(self.uniqueIDString)")
                    //retrieve data in regards to every set
                }
            }else{
                print("workout has been started already")
            }

            
        }else{
            print("stop")
            self.navigationItem.hidesBackButton = false
            self.addSetBtnOutlet.isEnabled = false
            self.saveBtnOutlet.title = "Start"
            //make the uitable view untouchable
            self.deactivateTableFlag = 0
            self.WipExCellTableView.reloadData()
            
            //have this save to firebase
            print("saving....")
            
            //working
            for x in self.setsWeightDict{
                print("key: \(x.key), value(sets): \(x.value)")
            }
            for y in self.repsDict{
                print("key: \(y.key), value(reps): \(y.value)")
            }
            
            if let tmp = UserDefaults.standard.string(forKey: flags.uniqueID){
                self.ref?.child("Users/\(self.userID)/HistoricalExercises/Completed \(self.exerciseID)/\(tmp)").setValue("1")
            }else{
                print("couldnt make the child node")
            }

        }
        

    
//
//        self.ref?.child("Users/\(self.userID)/HistoricalExercises/Completed \(self.exerciseID)/\(timestamp)").setValue("1")
    }
    
    //function to check users input called in WIPExerciseCell
    func checkWeightValidity(){
        self.saveBtnFlag = 0
        for setsCount in 0...exerciseSets-1{
//            print("sets count: \(setsCount)")
            let index = IndexPath(row: setsCount, section: 0)
            let cell: WIPExerciseCell = self.WipExCellTableView.cellForRow(at: index) as! WIPExerciseCell
            
            //check if inputs only have numbers
            if (Double(cell.setTxtField.text!) != nil) && (Int(cell.repsTxtField.text!) != nil) {
                cell.errorLabel.text = ""
                //add weight lifted and reps to dictionaries
                self.setsWeightDict[String(setsCount)] = cell.setTxtField.text!
                self.repsDict[String(setsCount)] = cell.repsTxtField.text!

            }else{
                //dont display error if value is null. just dont add it to the array.
                if cell.setTxtField.text! == "" && cell.repsTxtField.text! == ""{
                    cell.errorLabel.text = ""
                }else{
                    cell.errorLabel.text = "Invalid Number Entry"
                    self.saveBtnFlag = 1
                }
            }
            
            //activate or deactivate save button
            if saveBtnFlag == 0 {
                self.saveBtnOutlet.isEnabled = true
            }else{
                self.saveBtnOutlet.isEnabled = false
            }
            print(cell.setTxtField.text!)
        }
    }
    
    //called from WIPExerciseCell to deactivate save button during editing
    func deactivateSave(){
        self.saveBtnOutlet.isEnabled = false
    }
    
    //append a set
    @IBAction func addSetButton(_ sender: Any) {
        self.exerciseSets = self.exerciseSets + 1
        self.WipExCellTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
