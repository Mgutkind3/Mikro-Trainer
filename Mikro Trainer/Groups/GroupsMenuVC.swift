//
//  GroupsMenuVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 1/11/19.
//  Copyright © 2019 Michael Gutkind. All rights reserved.
//

import UIKit
import Firebase

class GroupsMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var groupList = [String]()//get this data from firebase
    var memberIDList = [String]()//shows the user id for every group
    var groupIDs = [String]()//each group id
    
    var ref: DatabaseReference?
    var userID = String()
    @IBOutlet weak var groupsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Your Groups"
        
        //database credentials
        ref = Database.database().reference()
        userID = String(Auth.auth().currentUser!.uid)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //call function to retrieve user's groups
        self.getAllMyGroups { groupList, memberIDList, groupIds in
            print("group list:", groupList)
            print("member id", memberIDList)
            print("group id", groupIds)
            self.groupList = groupList
            self.memberIDList = memberIDList
            self.groupIDs = groupIds
            self.groupsTableView.reloadData()
            
        }
    }
    
    //bring me to a page that lets me create a group
    @IBAction func createNewGroupBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewGroupVC") as! NewGroupVC
        //Change name of back button
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem // This will show in the next view
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let groupCell = self.groupsTableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as!
        GroupTableCell
        //set title of every cell
        groupCell.cellTitleLabel.text = self.groupList[indexPath.row]
        
        return groupCell
    }
    
    //let group be deleteable
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    //delete workout
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            //logic to remove member from the group
            
            //provide warning
            let removeAlert = UIAlertController(title: "Leave Group?", message: "Are you sure you want to remove yourself from the group: \(self.groupList[indexPath.row])?", preferredStyle: UIAlertController.Style.alert)
            removeAlert.addAction(UIAlertAction(title: "Remove Me!", style: UIAlertAction.Style.default, handler: { action in
                //remove me from database group and remove group from my groups
                //remove yourself from the group
                self.ref?.child("Groups").child(self.groupIDs[indexPath.row]).child("Members").child(self.memberIDList[indexPath.row]).setValue(nil)
                //remove group from your account
                self.ref?.child("Users").child(self.userID).child("Groups").child(self.groupIDs[indexPath.row]).setValue(nil)
                self.groupList.remove(at: indexPath.row)
                self.groupIDs.remove(at: indexPath.row)
                //reload table
                self.groupsTableView.reloadData()
            }))
            removeAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(removeAlert, animated: true, completion: nil)

        }
    }
    
    //select a group workout
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MyWorkoutsVC") as! MyWorkoutsVC
        vc.groupFlag = 1
        vc.groupID = self.groupIDs[indexPath.row]
        vc.vcTitle = "Group Workouts"
        //Change name of back button
        let backItem = UIBarButtonItem()
        backItem.title = "Groups"
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(vc, animated: true)
    }

}
