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

class AddGroupMembersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var emailAdrTxtFld: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var memberTableView: UITableView!
    var emailList = [String]()
    
    
    var ref: DatabaseReference?
    var userID = String()
    var email = String()
    var memberID = String()
    
    var groupTitle = String()
    var groupID = String()
    
    var contFlag = Int() //0 says its starting from scratch, 1 means its already pre built
    var newMemberList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add Group Members"
        if contFlag == 0{
            self.navigationItem.hidesBackButton = true
        }else{
            self.navigationItem.hidesBackButton = false
        }
        self.hideKeyboardWhenTappedAround()
        //database credentials
        ref = Database.database().reference()
        email = String(Auth.auth().currentUser!.email!)
        
        userID = String(Auth.auth().currentUser!.uid)
        //append self if this is a new group
        if contFlag == 0{
            self.emailList.append(email)
            self.newMemberList.append(email)
        }
        self.memberTableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if contFlag == 1{
            //get all the current members of  the group.
            self.getAllMyGroupMembers { (memberList) in
                self.emailList = memberList
                //dont add to new member list because they are already in the group
                self.memberTableView.reloadData()
            }
        }
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
                //add new member
                self.newMemberList.append(valid)
                print("adding to list")
                self.memberTableView.reloadData()
                //add email to list
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.emailList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.memberTableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath) as! MemberCell
        
        cell.cellTitle.text = self.emailList[indexPath.row]
        
        return cell
        
    }
    
    //let group be deleteable
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        //cant delete first person of the group
        if contFlag == 0{
            if indexPath.row == 0{
                return .none
            }else{
                return .delete
            }
        }else{
            //dont let anyone delete members if its a pre existing group
            return .none
        }
    }
    //delete cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            self.emailList.remove(at: indexPath.row)
            self.newMemberList.remove(at: indexPath.row)
            self.memberTableView.reloadData()
        }
    }
    
    //invite email addresses and close view controllers
    @IBAction func doneInvitingMembers(_ sender: Any) {
        var memberIDDict = [String:String]()
        
        
        for x in self.newMemberList {
            let newRef = self.ref?.child("Groups").child(self.groupID).child("Members").childByAutoId()
            let memberID = newRef?.key
            newRef?.setValue(x)
            //assign all member user emails to member id
            memberIDDict[x] = memberID
        }
        
        //https://stackoverflow.com/questions/41666044/how-to-get-userid-by-user-email-firebase-android
        //logic to go add this group to member's accounts if members exist in the system
        for x in self.newMemberList{
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
