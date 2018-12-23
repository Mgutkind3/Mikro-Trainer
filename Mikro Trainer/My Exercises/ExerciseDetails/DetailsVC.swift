//
//  DetailsVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 8/17/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class DetailsVC: UIViewController {

    @IBOutlet weak var baseRepsLbl: UILabel!
    @IBOutlet weak var baseSetsLbl: UILabel!
    @IBOutlet weak var baseWtLbl: UILabel!
    @IBOutlet weak var muscleGrpLbl: UILabel!
    @IBOutlet weak var exerDescrLbl: UITextView!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var exerciseImgView: UIImageView!
    
    //location for retrieved data
    var detailsDict = [String: String]()
    
    var exerciseTitle = String()
    var exerciseID = String()
    var ref: DatabaseReference?
    var userID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(exerciseTitle) Details"
        
        //set user id and database reference
        self.userID = String(Auth.auth().currentUser!.uid)
        ref = Database.database().reference()
        
        //format text box
        self.exerDescrLbl.isEditable = false
        
        print("DETAILS!")
        //load the information needed to complete this exercise
        self.getListOfExerciseDetails {
            print("done retrieving details")
            
            //set the text label values
            self.baseRepsLbl.text = "Base Reps: \(self.detailsDict["BaseReps"] ?? "")"
            self.baseSetsLbl.text = "Base Sets: \(self.detailsDict["BaseSets"] ?? "")"
            self.baseWtLbl.text = "Base Weight: \(self.detailsDict["BaseWeight"] ?? "")"
            self.exerDescrLbl.text = "Exercise Description: \(self.detailsDict["ExDescription"] ?? "")"
            self.muscleGrpLbl.text = "Muscle Group: \(self.detailsDict["MuscleGroup"] ?? "")"
            self.typeLbl.text = "Exercise Type: \(self.detailsDict["Type"] ?? "")"
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
