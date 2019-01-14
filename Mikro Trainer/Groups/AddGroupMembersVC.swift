//
//  AddGroupMembersVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 1/11/19.
//  Copyright © 2019 Michael Gutkind. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class AddGroupMembersVC: UIViewController {

    @IBOutlet weak var emailAdrTxtFld: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var listOfMembersLbl: UILabel!
    var emailList = [String]()
    
    var ref: DatabaseReference?
    var userID = String()
    var email = String()
    var memberID = String()
    
    var groupTitle = String()
    var groupID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add Group Members"
        self.navigationItem.hidesBackButton = true
        self.hideKeyboardWhenTappedAround()
        //database credentials
        ref = Database.database().reference()
        email = String(Auth.auth().currentUser!.email!)
        
        userID = String(Auth.auth().currentUser!.uid)
        self.emailList.append(email)
        
        
    }
    
    //enter button action
    //make sure the person isnt already in the group
    @IBAction func enterEmailAddress(_ sender: Any) {
        self.errorLabel.text = ""
        
        if let valid = self.emailAdrTxtFld.text{
            
            let validEmail = isValidEmail(testStr: valid)
        
            if(validEmail == false){
                self.errorLabel.text = "Invalid email format"
            }else{
                //make sure emails cant be entered more than once
                if self.emailList.contains(valid) {
                    self.errorLabel.text = "Email already entered"
                }else{
                self.emailAdrTxtFld.text = ""
                //append the email to a list
                self.emailList.append(valid)
                print("adding to list")
                displayMembersToAdd()
            //add email to list
                }
            }
        }
    }
    
    //function that will display the email addrsses entered
    func displayMembersToAdd(){
        var names = String()
        for x in self.emailList{
            names = names + x + ", "
        }
        self.listOfMembersLbl.text = names
    }
    
    //invite email addresses and close view controllers
    @IBAction func doneInvitingMembers(_ sender: Any) {
        var memberIDDict = [String:String]()
        
        
        for x in self.emailList {
            let newRef = self.ref?.child("Groups").child(self.groupID).child("Members").childByAutoId()
            let memberID = newRef?.key
            newRef?.setValue(x)
            //assign all member user emails to member id
            memberIDDict[x] = memberID
        }
        
        //https://stackoverflow.com/questions/41666044/how-to-get-userid-by-user-email-firebase-android
        //logic to go add this group to member's accounts if members exist in the system
        for x in self.emailList{
            let xCommas = x.replacingOccurrences(of: ".", with: ",")
            self.ref?.child("EmailToUID").child(xCommas).observeSingleEvent(of: .value, with: { snapshot in
                if let user = snapshot.value as? String{
                    print("user Exists: ", x, "user id: ", user)
                    self.ref?.child("Users").child(user).child("Groups").child(self.groupID).child(memberIDDict[x]!).setValue(self.groupTitle)
                }else{
                    print("user does not exist")
                }
                
            })
        }
        
        //https://stackoverflow.com/questions/47322379/swift-how-to-dismiss-all-of-view-controllers-to-go-back-to-root/47323593
        //dismissing views
        self.navigationController?.popToRootViewController(animated: true)

    }
    //https://www.hackingwithswift.com/example-code/uikit/how-to-send-an-email
    
    //validate email address
    //https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift/52282751
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    //slide out menu for options
    //https://medium.com/yay-its-erica/making-a-hamburger-slide-out-menu-in-swift-3-ef5249b6693e
    
}
