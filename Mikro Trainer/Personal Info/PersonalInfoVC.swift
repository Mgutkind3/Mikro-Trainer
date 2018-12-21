//
//  PersonalInfoVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 5/15/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

protocol SignOutMethod{
    func endSession()
}

class PersonalInfoVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var personalDict = [String: String]()
    var delegate:SignOutMethod?
    var ref: DatabaseReference?
    var userID = String()

    //text lables
    @IBOutlet weak var nameTxtFld: UITextField!
    @IBOutlet weak var heightTxtFld: UITextField!
    @IBOutlet weak var weightTxtFld: UITextField!
    @IBOutlet weak var genderTxtFld: UITextField!
    @IBOutlet weak var dobTxtFld: UITextField!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    //options for text fields
    var gender = ["Male", "Female", "Other"]
    var heightFt = [String]()
    var heightInch = [String]()
    var weights = [String]()
    var weightLabels = ["lbs", "Kg"]
    var masterPicker = [[String]]()
    
    //create date pickers
    private var datePicker: UIDatePicker?
    private var weightPicker: UIPickerView?
    private var heightPicker: UIPickerView?
    private var genderPicker: UIPickerView?
    
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
            self.weightTxtFld.text = "\(weightNum) \(weightLabel)"
            self.personalDict["UserWeight"] = self.weightTxtFld.text
            
        }else if pickerView == heightPicker{
            let feet = masterPicker[0][pickerView.selectedRow(inComponent: 0)]
            let inches = masterPicker[1][pickerView.selectedRow(inComponent: 1)]
            self.heightTxtFld.text = "\(feet) \(inches)"
            self.personalDict["UserHeight"] = self.heightTxtFld.text
        }else{
            //spot for male or female or other
            self.genderTxtFld.text = gender[row]
            self.personalDict["UserSex"] = self.genderTxtFld.text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarItem.title = "Me"
        self.navigationItem.title = "Personal Info"
        self.tabBarController?.tabBar.isHidden = true
        self.hideKeyboardWhenTappedAround()
        ref = Database.database().reference()
        self.userID = String(Auth.auth().currentUser!.uid)

        //Text Labels to
        self.nameTxtFld.text = self.personalDict["UserName"]!
        self.heightTxtFld.text = self.personalDict["UserHeight"]!
        self.weightTxtFld.text = self.personalDict["UserWeight"]!
        self.genderTxtFld.text = self.personalDict["UserSex"]!
        self.dobTxtFld.text = self.personalDict["UserAge"]!
        
        //retrieve the profile pricture
//        https://www.youtube.com/watch?v=b1vrjt7Nvb0&t=5s //set up
//        https://www.youtube.com/watch?v=GX4mcOOUrWQ //retrieve image
        
        //logic to set profile pic
        print(" profile image url before function: \(self.personalDict["ProfileImageDownload"])")
        setProfPic()
        
        // Do any additional setup after loading the view.
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
        genderTxtFld.inputView = genderPicker
        heightTxtFld.inputView = heightPicker
        weightTxtFld.inputView = weightPicker
        dobTxtFld.inputView = datePicker
        
        //disable everything initially
        self.nameTxtFld.isEnabled = false
        self.weightTxtFld.isEnabled = false
        self.heightTxtFld.isEnabled = false
        self.genderTxtFld.isEnabled = false
        self.dobTxtFld.isEnabled = false
    }
    
    //set profile picture
    func setProfPic(){
        print("SETTING PROFILE PIC")
        //logic to set profile pic
        print(" profile image url: \(self.personalDict["ProfileImageDownload"])")
        if let profileImageURL = self.personalDict["ProfileImageDownload"] {
            let url = URL(string: profileImageURL)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                
                //donwload having an error so lets force quit
                if error != nil{
                    print(error as Any)
                    return
                }else{
                    let image = UIImage(data: data!)
                    self.profilePicImageView.contentMode = .scaleAspectFill
                    self.profilePicImageView.image = image
                }
            }).resume()
        }else{
            print("profileImageURL is null")
            return
        }
    }
    
    //function that formats and sets date for date of birth
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        dobTxtFld.text = dateFormatter.string(from: datePicker.date)
        self.personalDict["UserAge"] = dobTxtFld.text
    }
    
    //function to edit current info
    @IBAction func editPersonalInfo(_ sender: Any) {
        if (self.editBtn.title(for: .normal) == "Done"){
            self.editBtn.setTitle("Edit", for: .normal)
            self.nameTxtFld.isEnabled = false
            self.weightTxtFld.isEnabled = false
            self.heightTxtFld.isEnabled = false
            self.genderTxtFld.isEnabled = false
            self.dobTxtFld.isEnabled = false
            //get updated name
            self.personalDict["UserName"] = self.nameTxtFld.text
            
            print(personalDict)
            //logic to send all the info to the database and update it
            let personalInfoFields = ["UserName", "UserAge", "UserSex", "UserHeight", "UserWeight"]
            
            //set the value of the personal info fields
            for x in personalInfoFields{
                self.ref?.child("Users").child(self.userID).child("PersonalData").child(x).setValue(self.personalDict[x])
            }
        }else{
            //start editing personal information fields
            self.editBtn.setTitle("Done", for: .normal)
            self.nameTxtFld.isEnabled = true
            self.weightTxtFld.isEnabled = true
            self.heightTxtFld.isEnabled = true
            self.genderTxtFld.isEnabled = true
            self.dobTxtFld.isEnabled = true
        }
        
    }
    
    
    //function to sign out of user profile
    @IBAction func signOutBtn(_ sender: Any) {
        print("Goodbye")
            do {
            try Auth.auth().signOut()
            } catch{
            print("problems logging out")
            }
        self.delegate?.endSession()
        self.navigationController?.popViewController(animated: true)
    }
    
    //go to settings page
    @IBAction func settingsPage(_ sender: Any) {
        print("settings")
        //space to enable biometric security
        //https://codeburst.io/biometric-authentication-using-swift-bb2a1241f2be
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}



