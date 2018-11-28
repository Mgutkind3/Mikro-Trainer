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
import FirebaseStorage

class NewAccountVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var registrationErrorLabel: UILabel!
    @IBOutlet weak var regEmailTextField: UITextField!
    @IBOutlet weak var firstPwdTextField: UITextField!
    @IBOutlet weak var secondPwdTextField: UITextField!
    
    //Optional text fields
    @IBOutlet weak var genderTextField: UITextField!
    var gender = ["Male", "Female", "Other"]
    @IBOutlet weak var heightTextField: UITextField!
    var heightFt = [String]()
    var heightInch = [String]()
    @IBOutlet weak var weightTextField: UITextField!
    var weights = [String]()
    var weightLabels = ["lbs", "Kg"]
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    var masterPicker = [[String]]()
    
    private var datePicker: UIDatePicker?
    private var weightPicker: UIPickerView?
    private var heightPicker: UIPickerView?
    private var genderPicker: UIPickerView?
    
    //dictionary to contain all personal info for database population
    var personalInfoDict = ["UserName": "",
                            "UserAge": "",
                            "UserSex": "",
                            "UserHeight": "",
                            "UserWeight": ""
    ]
    
    var ref: DatabaseReference?
    var userID = String()
    
    @IBOutlet weak var UISelfieView: UIImageView!
    
    //return amount of picker columns
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == weightPicker || pickerView == heightPicker{
            return 2
        }else {
            return 1
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == weightPicker{
            //append to a master array
            masterPicker.removeAll()
            masterPicker.append(weights)
            masterPicker.append(weightLabels)
            
            return self.masterPicker[component].count
        }else if pickerView == heightPicker{
            //append to a master array
            masterPicker.removeAll()
            masterPicker.append(heightFt)
            masterPicker.append(heightInch)
            
            return self.masterPicker[component].count
        }else{
            //male or female option
            return gender.count
        }

    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == weightPicker || pickerView == heightPicker{
            return masterPicker[component][row]
        }else {
            return gender[row]//one dimensional array
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == weightPicker{
            let weightNum = masterPicker[0][pickerView.selectedRow(inComponent: 0)]
            let weightLabel = masterPicker[1][pickerView.selectedRow(inComponent: 1)]
            self.weightTextField.text = "\(weightNum) \(weightLabel)"
            self.personalInfoDict["UserWeight"] = self.weightTextField.text
            
        }else if pickerView == heightPicker{
            let feet = masterPicker[0][pickerView.selectedRow(inComponent: 0)]
            let inches = masterPicker[1][pickerView.selectedRow(inComponent: 1)]
            self.heightTextField.text = "\(feet) \(inches)"
            self.personalInfoDict["UserHeight"] = self.heightTextField.text
        }else{
            //spot for male or female
            self.genderTextField.text = gender[row]
            self.personalInfoDict["UserSex"] = self.genderTextField.text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.hideKeyboardWhenTappedAround()
        
        //append weight amounts into a single array
        for x in 35...450{
            weights.append(String(x))
        }
        
        //append height in feet to a list
        for x in 1...7{
            self.heightFt.append(String(x) + " Ft.")
        }
        for x in 0...11{
            self.heightInch.append(String(x) + " In.")
        }
        
        //date of birth text box
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.maximumDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        datePicker?.addTarget(self, action: #selector(NewAccountVC.dateChanged(datePicker:)), for: .valueChanged)
        
        //weight picker view
        weightPicker = UIPickerView()
        weightPicker?.delegate = self
        weightPicker?.dataSource = self
        
        //height picker view
        heightPicker = UIPickerView()
        heightPicker?.delegate = self
        heightPicker?.dataSource = self
        
        //gender picker view
        genderPicker = UIPickerView()
        genderPicker?.delegate = self
        genderPicker?.dataSource = self
        
        //set the picker input views
        genderTextField.inputView = genderPicker
        heightTextField.inputView = heightPicker
        weightTextField.inputView = weightPicker
        dobTextField.inputView = datePicker
    }
    
    //function that formats and sets date for date of birth
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        dobTextField.text = dateFormatter.string(from: datePicker.date)
        self.personalInfoDict["UserAge"] = dobTextField.text
    }

    //button to confirm registration of new user
    @IBAction func registerNewUserButton(_ sender: Any) {
        registrationErrorLabel.text = ""
        let email = regEmailTextField.text
        let password = firstPwdTextField.text
        
        //make sure all fields have been populated
        if email == "" || password == "" || secondPwdTextField.text == "" || nameTextField.text == ""{
            registrationErrorLabel.text = "Please enter all required fields"
            return
        }
        //make sure the passwords match
        if password != secondPwdTextField.text{
            registrationErrorLabel.text = "The passwords you've entered do not match"
            return
        }
        
        self.personalInfoDict["UserName"] = nameTextField.text
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
        
        //set the value of the personal info fields
        for x in personalInfoFields{
            self.ref?.child("Users").child(self.userID).child("PersonalData").child(x).setValue(self.personalInfoDict[x])
        }
        //start nodes for schema development
        self.ref?.child("Users").child(self.userID).child("MyExercises").setValue("")
        self.ref?.child("Users").child(self.userID).child("MyFriends").setValue("")
        self.ref?.child("Users").child(self.userID).child("MyWorkouts").setValue("")
        self.ref?.child("Users").child(self.userID).child("HistoricalExercises").setValue("")
        
    }
    
    //take a selfie button
    @IBAction func takeASelfie(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //do something with the most recent image picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            UISelfieView.contentMode = .scaleToFill
            UISelfieView.image = pickedImage
            picker.dismiss(animated: true, completion: nil)
            
            print(pickedImage)
            
            let storageRef = Storage.storage().reference().child("profile.png")
            if let uploadData = UISelfieView.image!.pngData() {
                
                storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                    
                    if error != nil {
                        print(error)
                        return
                    }
                    print(metadata)
                }
            }
            


        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
