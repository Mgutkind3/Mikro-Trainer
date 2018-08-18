//
//  NewAccountVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 5/15/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class NewAccountVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var registrationErrorLabel: UILabel!
    @IBOutlet weak var regEmailTextField: UITextField!
    @IBOutlet weak var firstPwdTextField: UITextField!
    @IBOutlet weak var secondPwdTextField: UITextField!
    var ref: DatabaseReference?
    var userID = String()
    
    @IBOutlet weak var UISelfieView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.hideKeyboardWhenTappedAround()
    }

    //button to confirm registration of new user
    @IBAction func registerNewUserButton(_ sender: Any) {
        registrationErrorLabel.text = ""
        let email = regEmailTextField.text
        let password = firstPwdTextField.text
        
        //make sure all fields have been populated
        if email == "" || password == "" || secondPwdTextField.text == ""{
            registrationErrorLabel.text = "Please enter all required fields"
            return
        }
        //make sure the passwords match
        if password != secondPwdTextField.text{
            registrationErrorLabel.text = "The passwords you've entered do not match"
            return
        }
        
        Auth.auth().createUser(withEmail: email!, password: password!, completion: { user, error in
            if let firebaseError = error{
                print(firebaseError.localizedDescription)
                self.registrationErrorLabel.text = String(firebaseError.localizedDescription)
                return
            }
            self.userID = String(Auth.auth().currentUser!.uid)
            print("user id: \(self.userID)")
            
            //call function to build backend schema for specific users
            self.addNewUserNodes()
            //if error is not printed send a success message and dismiss modal view
            print("Success!")
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    //button to cancel registration
    @IBAction func cancelNewAccountButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //create personal data section of the database
    func addNewUserNodes(){
        let personalInfoFields = ["UserName", "UserAge", "UserSex", "UserHeight", "UserWeight"]
        for x in personalInfoFields{
            self.ref?.child("Users").child(self.userID).child("PersonalData").child(x).setValue("")
        }
        //start nodes for schema development
        self.ref?.child("Users").child(self.userID).child("MyExercises").setValue("")
        self.ref?.child("Users").child(self.userID).child("MyFriends").setValue("")
        self.ref?.child("Users").child(self.userID).child("MyWorkouts").setValue("")
        self.ref?.child("Users").child(self.userID).child("HistoricalExercises").setValue("")
        
    }
    
    //take a selfie button
    @IBAction func takeASelfie(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //do something with the most recent image picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            UISelfieView.contentMode = .scaleToFill
            UISelfieView.image = pickedImage
            picker.dismiss(animated: true, completion: nil)
            
//            //new code
//            var data = NSData()
//            data = UIImageJPEGRepresentation(UISelfieView.image!, 0.8)! as NSData
//            // set upload path
//            let filePath = "\(Auth.auth().currentUser!.uid)/\("userPhoto")"
//            let metaData = FIRStorageMetadata()
//            metaData.contentType = "image/jpg"
//            self.storageRef.child(filePath).putData(data, metadata: metaData){(metaData,error) in
//                if let error = error {
//                    print(error.localizedDescription)
//                    return
//                }else{
//                    //store downloadURL
//                    let downloadURL = metaData!.downloadURL()!.absoluteString
//                    //store downloadURL at database
//                    self.databaseRef.child("users").child(FIRAuth.auth()!.currentUser!.uid).updateChildValues(["userPhoto": downloadURL])
//                }
//                
//            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
