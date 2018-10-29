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
//    static let switchState = "" //deactivated
//    static let userPwd = ""
//    static let userEmail = ""
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
    var actualSetCount = 0
    var mostRecentTimestamp = ""
    
    //lists to keep track of weights and reps
    var setsWeightDict: [String: String] = [:]
    var repsDict: [String: String] = [:]
    
    //list to keep rep and weight place holders
    var prevWeightList = [String]()
    var prevRepsList = [String]()
    
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
        
        //get most recent workout data
        self.getMostRecentExercise {
            //call function to set placeholders with previous info
            if self.mostRecentTimestamp == ""{
                //do nothing
            }else{
                self.getSpecificRepsSetsData {
                    print("done")
                }
                //retrieve last values placeholders
            }
        }
        
        self.title = exerciseTitle

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //get all of the information in regards to this exercise
        getMyExerciseData {
            self.WipExCellTableView.reloadData()
            
            if self.exerciseSets != 0 {
            for setsCount in 0...self.exerciseSets-1{
                let index = IndexPath(row: setsCount, section: 0)
                let cell: WIPExerciseCell = self.WipExCellTableView.cellForRow(at: index) as! WIPExerciseCell
                
                //if never done before dont pre-populate placeholders
                if self.prevRepsList.count == 0 {
                //nothing
            }else{
                print("prevReps count= \(self.prevRepsList.count)")
                print("indexPath.row2: \(setsCount)")
                    //if the exercise was already completed for this workout set the value not the placeholder
                    if let continueFlag =  UserDefaults.standard.string(forKey: flags.hasStartedFlag){
                        if continueFlag == "0"{
                            cell.setTxtField.placeholder = self.prevWeightList[setsCount]
                            cell.repsTxtField.placeholder = self.prevRepsList[setsCount]
                            cell.setTxtField.text = self.prevWeightList[setsCount]
                            cell.repsTxtField.text = self.prevRepsList[setsCount]
                        }else{
                            cell.setTxtField.text = self.prevWeightList[setsCount]
                            cell.repsTxtField.text = self.prevRepsList[setsCount]
                        }
                        
                    }
                }
            }
                self.WipExCellTableView.reloadData()
            }
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
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row == 0 {
            return .none
        }else{
            return .delete
        }

    }
    
    //delete set
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            
            //if row is deleted and move row below it then move their values as well
            if (self.exerciseSets-(indexPath.row+1)) == 0{
//                print("nothing underneath it, sets:\(self.exerciseSets), indexPath.row: \(indexPath.row)")
            }else{
//                print("something underneath it, sets:\(self.exerciseSets), indexPath.row: \(indexPath.row)")

                //logic to move values up into the deleted slot
                var i = indexPath.row
                for _ in (indexPath.row+2)...self.exerciseSets{
                    //cell 1
                    let cell1Index = IndexPath(row: i, section: 0)
                    let cell1: WIPExerciseCell = self.WipExCellTableView.cellForRow(at: cell1Index) as! WIPExerciseCell
                    //cell 2
                    let cell2Index = IndexPath(row: i+1, section: 0)
                    let cell2: WIPExerciseCell = self.WipExCellTableView.cellForRow(at: cell2Index) as! WIPExerciseCell
                    //move values
                    cell1.setTxtField.text = cell2.setTxtField.text
                    cell1.repsTxtField.text = cell2.repsTxtField.text
                    i = i+1
                }
            }
            
            //delete entire sets_reps node
            checkWeightValidity()
            self.ref?.child("Users/\(self.userID)/HistoricalExercises/Completed \(self.exerciseID)/\(self.uniqueIDString)/sets_reps").setValue(nil)
            //delete the data if the set was deleted
            self.exerciseSets = self.exerciseSets-1
            self.WipExCellTableView.reloadData()
            self.repsDict[String(indexPath.row)] = ""
            self.setsWeightDict[String(indexPath.row)] = ""
            //delete from firebase eventually
            self.ref?.child("Users/\(self.userID)/HistoricalExercises/Completed \(self.exerciseID)/\(self.uniqueIDString)/sets_reps/\(indexPath.row+1)").setValue(nil)

        }
    }
    
    //set up each specific row
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
//                    print("set started string to: \(UserDefaults.standard.string(forKey: flags.hasStartedFlag) as Any)")
                    
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
//                    print("testing: \(UserDefaults.standard.string(forKey: flags.uniqueID))")
                    self.uniqueIDString = (UserDefaults.standard.string(forKey: flags.uniqueID))!
                        print("continue flag: \(continueFlag)")
                        print("unique string: \(self.uniqueIDString)")
                        //retrieve data in regards to every set
//                    } else {
//                        print("problem fetching unique string")
//                    }
                    //continuing workout

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
            self.checkWeightValidity()
            
            //have this save to firebase
            print("saving....")
            saveSetData()
        }
    }
    
    //function to save specific set metadat (reps,sets, etc...)
    func saveSetData(){
        if let tmp = UserDefaults.standard.string(forKey: flags.uniqueID){
            self.actualSetCount = 0
            //check all the sets
            for q in 0...self.exerciseSets-1{
                if (self.setsWeightDict[String(q)] != "") && self.repsDict[String(q)] != "" {
                    self.actualSetCount = self.actualSetCount+1
                    //save the date
                    self.ref?.child("Users/\(self.userID)/HistoricalExercises/Completed \(self.exerciseID)/\(tmp)/Date").setValue(tmp)
                    
                    print(" weight: \(String(describing: self.setsWeightDict[String(q)])) and reps: \(String(describing: self.repsDict[String(q)])) at: \(q)")
                    
                    let setInfo = ["weight","reps","set"]
                    let dataDict = ["weight": self.setsWeightDict[String(q)], "reps":self.repsDict[String(q)], "set": String(self.actualSetCount)]
                    
                    
                    //store set metadata in historical
                    for x in setInfo{
                        self.ref?.child("Users/\(self.userID)/HistoricalExercises/Completed \(self.exerciseID)/\(tmp)/sets_reps/\(self.actualSetCount)/\(x)").setValue("\(dataDict[x] as! String)")
                    }

                }
                //dont ever reach here
            }
            
            //never let there be no sets
            if self.actualSetCount == 0{
                self.actualSetCount = 1
            }
            
            //save data in myExercises
            let workoutDetails = [self.exerciseTitle, self.uniqueIDString, String(self.actualSetCount), self.exerciseID ] as [Any]
            let workoutFields = ["Name", "Timestamp", "BaseSets", "ExerciseID" ]
            var i = 0
            for x in workoutFields {
                //make my list customizeable/yet gets original info from Exercises Branch
                self.ref?.child("Users").child(self.userID).child("MyExercises").child("My Exercise \(self.exerciseID)").child(x).setValue(workoutDetails[i])
                i=i+1
            }
        }else{
            print("couldnt make the child node")
        }
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
                    self.setsWeightDict[String(setsCount)] = cell.setTxtField.text!
                    self.repsDict[String(setsCount)] = cell.repsTxtField.text!
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
        let newItem = IndexPath(row: self.exerciseSets-1, section: 0)
        let cell: WIPExerciseCell = self.WipExCellTableView.cellForRow(at: newItem) as! WIPExerciseCell
        cell.setTxtField.text = ""
        cell.repsTxtField.text = ""
        self.WipExCellTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
