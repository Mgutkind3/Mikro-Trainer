//
//  AddExcerciseVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 5/16/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class AddExcerciseVC: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var excerciseNameTxtField: UITextField!
    @IBOutlet weak var muscGrpTxtField: UITextField!
    @IBOutlet weak var wtTxtField: UITextField!
    @IBOutlet weak var setTxtField: UITextField!
    @IBOutlet weak var repsTxtField: UITextField!
    @IBOutlet weak var addExcerciseErrorLabel: UILabel!
    @IBOutlet weak var shortDescBox: UITextView!
    @IBOutlet weak var aerobicNonAeroSegment: UISegmentedControl!
    @IBOutlet weak var exerciseImgView: UIImageView!
    
    var ref: DatabaseReference?
    var userID = String()
    var exName = String()
    var mGrp = String()
    var wt = String()
    var sets = String()
    var reps = String()
    var exID = String()
    var aero = String()
    var desc = String()
    var highestID = 0
    var descFlag = 0 //not edited yet
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        ref = Database.database().reference()
        userID = String(Auth.auth().currentUser!.uid)
        shortDescBox.delegate = self
        shortDescBox.dataDetectorTypes = UIDataDetectorTypes.all

    }
    
    //set value to null when beginning to edit
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descFlag == 0{
            self.shortDescBox.text = ""
            descFlag = 1
        }else{
            //dont reset text and do nothing
        }
    }
    
    //upload image to firebase
    @IBAction func uploadImageBtn(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        image.allowsEditing = false
        self.present(image, animated: true)
        {
            //after presenting is complete
        }
    }
    
    //get imahe and place it in the view befor submission
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage{
            
            self.exerciseImgView.contentMode = .scaleAspectFill
            self.exerciseImgView.image = image
            
        }else{
            //error
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func submitNewExerciseBtn(_ sender: Any) {
        addExcerciseErrorLabel.text = ""
        addExcerciseErrorLabel.textColor = UIColor.red
        
        exName = excerciseNameTxtField.text!
        mGrp = muscGrpTxtField.text!
        wt = wtTxtField.text!
        sets = setTxtField.text!
        reps = repsTxtField.text!
        desc = shortDescBox.text!
        
        //get aerobic value depending on segmented control
        if self.aerobicNonAeroSegment.selectedSegmentIndex == 0{
            aero = self.aerobicNonAeroSegment.titleForSegment(at: 0)!
        }else{
            aero = self.aerobicNonAeroSegment.titleForSegment(at: 1)!
        }
        print("aero is: \(aero)")
        
        
        var i = 0//counter to make sure arrays mirror
        
        //make sure all fields are filled in
        if exName == "" || mGrp == "" || wt == "" || sets == "" || reps == "" || desc == "Short description of how to complete the workout." || desc == "" {
            addExcerciseErrorLabel.text = "Please fill in all the fields"
            return
        }
        
        //call exercise branch and see what number of exercises we are at completion must be completed before this contents is run
        exerciseNumber(completion: { () in
            //            print("highest id check: \(self.highestID)")
            self.exID = String(self.highestID)
            
            let workoutDetails = [self.exName, self.mGrp, self.wt, self.sets, self.reps, self.exID, self.aero, self.desc ]
            let workoutFields = ["Name", "MuscleGroup","BaseWeight", "BaseSets", "BaseReps", "ExerciseID", "Type", "ExDescription" ]
            
            for x in workoutFields {
                self.ref?.child("Exercises").child(self.exID).child(x).setValue(workoutDetails[i])
                i = i + 1
            }
            
            //fucntion to upload image to firebase storage
            self.uploadImgToFir()
        })
        

        
        //clear all text fields
        excerciseNameTxtField.text = ""
        muscGrpTxtField.text = ""
        wtTxtField.text = ""
        setTxtField.text = ""
        repsTxtField.text = ""
        shortDescBox.text = "Short description of how to complete the workout."
        addExcerciseErrorLabel.textColor = UIColor.green
        addExcerciseErrorLabel.text = "Success!"
        descFlag = 0
        self.navigationController?.popViewController(animated: true)//close current view controller upon successful completion?

    }
    
    //upload image to firebase
    func uploadImgToFir(){
        
        if let pickedImage = self.exerciseImgView.image{
        //make image small for storing online
        let compressedImage = pickedImage.resized(withPercentage: 0.1)
        
        //name the image uniquely
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("\(imageName).png")
        if let uploadData = compressedImage!.pngData() {
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                
                if error != nil {
                    print(error as Any)
                    return
                }
                //get download url and save it in the database
//                let downloadURL = (metadata?.downloadURL()!.absoluteString)!
                
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    //upload new downloadable link url
                    self.ref?.child("Exercises/\(self.exID)").child("StorageURL").setValue("\(downloadURL)")

                }
                
//                //upload new downloadable link url
//                self.ref?.child("Exercises/\(self.exID)").child("StorageURL").setValue(downloadURL)
            }
        }
        }else{
            print("no image selected")
        }
    }

    
    //find the highest exercise number recorded in the database
    func exerciseNumber(completion: @escaping ()->()){
        //get the highest exercise number and add 1 to it
            self.ref?.child("Exercises").observeSingleEvent(of: .value, with: { snapshot in
                //populate array with all exercise id's
                if let dict = snapshot.value as? [NSObject] {
                    for y in (dict) {
                let obj = y as? NSDictionary
                if let exerciseID = obj?["ExerciseID"] as? String {
                    let exerciseIDInt = Int(exerciseID)
                    
                    // find the highest user id (if there are any) and create a new exercise id
                    if exerciseIDInt! >= self.highestID{
                        self.highestID = exerciseIDInt! + 1
                    }
                }
            }
                completion()
                }else{
                //if no exercises available start database at unique ID of 0
                self.highestID = 0
                completion()
                }
        })

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
