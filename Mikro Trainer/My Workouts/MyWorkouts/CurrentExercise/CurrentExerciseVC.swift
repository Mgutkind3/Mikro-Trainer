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

class CurrentExerciseVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CellCheckDelegate {
    
    @IBOutlet weak var saveBtnOutlet: UIBarButtonItem!
    var exerciseTitle = ""
    var exerciseID = ""
    var exerciseSets = 0
    var exerciseReps = 0
    var saveBtnFlag = 0 //deactivated
    var ref: DatabaseReference?
    var userID = String()
    
    @IBOutlet weak var WipExCellTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.saveBtnOutlet.isEnabled = false
        
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wipExCell = self.WipExCellTableView.dequeueReusableCell(withIdentifier: "WipExCell", for: indexPath) as! WIPExerciseCell
        
        wipExCell.setLabel.text = "Set \(indexPath.row)"
        wipExCell.setTxtField.text = "0.0"
        wipExCell.errorLabel.text = ""
        wipExCell.errorLabel.textColor = UIColor.red
        wipExCell.delegate = self
        
        return wipExCell
    }
    

    @IBAction func saveExerBtn(_ sender: Any) {
        print("saving....")
        
    }
    
    //function to check users input called in WIPExerciseCell
    func checkWeightValidity(){
        self.saveBtnFlag = 0
        for setsCount in 0...exerciseSets-1{
            print("sets count: \(setsCount)")
            let index = IndexPath(row: setsCount, section: 0)
            let cell: WIPExerciseCell = self.WipExCellTableView.cellForRow(at: index) as! WIPExerciseCell
            
            //check if inputs only have numbers
            if let d = Double(cell.setTxtField.text!){
                print("do something with: \(d)")
                cell.errorLabel.text = ""
            }else{
                cell.errorLabel.text = "Invalid Number Entry"
                self.saveBtnFlag = 1
            }
            
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
    
    //might not need this
    @IBAction func finishExerciseBtn(_ sender: Any) {
        
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
