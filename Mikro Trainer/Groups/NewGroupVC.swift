//
//  NewGroupVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 1/11/19.
//  Copyright © 2019 Michael Gutkind. All rights reserved.
//

import UIKit
import Firebase

class NewGroupVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupDescription: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var GroupImageView: UIImageView!
    @IBOutlet weak var nxtBtnOutlet: UIBarButtonItem!
    
    var ref: DatabaseReference?
    var userID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Create New Group"
        navigationItem.backBarButtonItem?.title = "Cancel"
        //limit the amount a user can type in the text box
        groupNameTextField.delegate = self
        groupDescription.delegate = self
        self.nxtBtnOutlet.isEnabled = false
        self.hideKeyboardWhenTappedAround()
        
        //database credentials
        ref = Database.database().reference()
        userID = String(Auth.auth().currentUser!.uid)
        
        // Do any additional setup after loading the view.
    }
    
    //triggers if the title text field is updated
    @IBAction func titleUpdated(_ sender: Any) {
        if self.groupNameTextField.text != ""{
            self.nxtBtnOutlet.isEnabled = true
        }else{
            self.nxtBtnOutlet.isEnabled = false
        }
    }
    
    @IBAction func uploadGroupPicture(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        image.allowsEditing = true
        self.present(image, animated: true)
        {
            //after presenting is complete
        }
    }
    
    //get image and place it in the view befor submission
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        //
        var selectedImage = UIImage()
        
        if let editedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            selectedImage = editedImage
        }else if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            selectedImage = pickedImage
        }else{
            //error
        }
            
            self.GroupImageView.contentMode = .scaleAspectFill
            self.GroupImageView.image = selectedImage
            
        self.dismiss(animated: true, completion: nil)
    }
    
    //go to add members page
    @IBAction func nextBtn(_ sender: Any) {
        
        if self.groupNameTextField.text == ""{
            self.errorLabel.text = "Please enter a title for your group"
        }else{
        
        //create group in database
        let newRef = self.ref?.child("Groups").childByAutoId()
        let groupID = newRef?.key
            
        //set group metadata in database
        self.ref?.child("Groups").child(groupID!).child("Info").child("GroupName").setValue(self.groupNameTextField.text)
        self.ref?.child("Groups").child(groupID!).child("Info").child("GroupDescription").setValue(self.groupDescription.text)
            
        //add group and group name to user's groups sections
//        self.ref?.child("Users").child(self.userID).child("Groups").child(groupID!).setValue(self.groupNameTextField.text)
        
        //store the image in storage
        if let image = self.GroupImageView.image{
        //make image small for storing online
            let compressedImage = image.resized(withPercentage: 0.1)
        
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
                //update for firebase download url
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    self.ref?.child("Groups").child(groupID!).child("Info").child("ProfilePicDownloadURL").setValue("\(downloadURL)")
                }
                let imageName = "\(imageName).png"
                
                //upload new downloadable link and imageName
//                self.ref?.child("Groups").child(groupID!).child("Info").child("ProfilePicDownloadURL").setValue(downloadURL)
                self.ref?.child("Groups").child(groupID!).child("Info").child("ProfileImageName").setValue(imageName)
                
            }
        }
        }else{
            print("no image available")
        }
        
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddGroupMembersVC") as! AddGroupMembersVC
        //pass the group id variable
        vc.groupTitle = self.groupNameTextField.text!
        vc.groupID = groupID!
        vc.contFlag = 0
        navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let count = text.count + string.count - range.length
        return count <= 20
    }

}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

