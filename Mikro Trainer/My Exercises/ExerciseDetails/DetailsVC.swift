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
    var storage: Storage!
    var userID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(exerciseTitle) Details"
        
        //set user id and database reference
        self.userID = String(Auth.auth().currentUser!.uid)
        ref = Database.database().reference()
        storage = Storage.storage()
        
        //format text box
        self.exerDescrLbl.isEditable = false
        
        print("DETAILS!")
        //load the information needed to complete this exercise
        self.getListOfExerciseDetails {
            
            //get image for display
            self.exerImg()
            
            //set the text label values
            self.baseRepsLbl.text = "Base Reps: \(self.detailsDict["BaseReps"] ?? "")"
            self.baseSetsLbl.text = "Base Sets: \(self.detailsDict["BaseSets"] ?? "")"
            self.baseWtLbl.text = "Base Weight: \(self.detailsDict["BaseWeight"] ?? "")"
            self.exerDescrLbl.text = "Exercise Description: \(self.detailsDict["ExDescription"] ?? "")"
            self.muscleGrpLbl.text = "Muscle Group: \(self.detailsDict["MuscleGroup"] ?? "")"
            self.typeLbl.text = "Exercise Type: \(self.detailsDict["Type"] ?? "")"
            
        }
        
    }
    
    
    //get image to display for each exercise
    func exerImg(){
        //set profile picture
            print("SETTING PROFILE PIC")
            //logic to set profile pic
            if let profileImageURL = self.detailsDict["StorageURL"] {
//                let url = URL(string: profileImageURL)
                let httpsReference = self.storage.reference(forURL: profileImageURL)
//                URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                //download to memory and limit to 1mb
                 httpsReference.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                    
                    //donwload having an error so lets force quit
                    if error != nil{
                        print(error as Any)
                        return
                    }else{
                        let image = UIImage(data: data!)
                        self.exerciseImgView.contentMode = .scaleAspectFill
                        self.exerciseImgView.image = image
                    }
                }
            }else{
                print("exercise image is not available")
            }
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
