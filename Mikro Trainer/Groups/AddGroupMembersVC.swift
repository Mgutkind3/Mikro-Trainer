//
//  AddGroupMembersVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 1/11/19.
//  Copyright © 2019 Michael Gutkind. All rights reserved.
//

import UIKit

class AddGroupMembersVC: UIViewController {

    var groupID = String()
    @IBOutlet weak var emailAdrTxtFld: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var listOfMembersLbl: UILabel!
    var emailList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add Group Members"
        self.navigationItem.hidesBackButton = true
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
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
                self.emailAdrTxtFld.text = ""
                //append the email to a list
                self.emailList.append(valid)
                print("adding to list")
                displayMembersToAdd()
            //add email to list
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
    
}
