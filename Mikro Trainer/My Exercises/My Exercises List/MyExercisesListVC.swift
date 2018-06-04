//
//  MyExercisesListVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 6/3/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MyExercisesListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var ref: DatabaseReference?
    var MyExNameList = [String]()
    var MyExIDList = [String]()
    let allExVC = AllExercisesVC()
    var userID = String()
    @IBOutlet weak var myExercisesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userID = String(Auth.auth().currentUser!.uid)
        ref = Database.database().reference()
        
        //set user ID in AllExercisesVC before calling any function
        self.allExVC.setUserID()
        
        //populate table view with list of my exercises from other classes functions
        self.allExVC.getMyList {
            self.MyExNameList = self.allExVC.myExerciseNameList
            self.MyExIDList = self.allExVC.myExerciseIDList
            self.myExercisesTableView.reloadData()
        }

    }
    
    //build number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (MyExNameList.count)
    }
    
    //build each specific cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = self.myExercisesTableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! MyExercisesTableCell
        
        //customize each specific cell
        myCell.MyCellLabel.text = MyExNameList[indexPath.row]
        
        return myCell
    }
    
    //delete an exercise from my list
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            print("Delete row: \(MyExNameList[indexPath.row])")
            print("id number: \(MyExIDList[indexPath.row])")
            
            //remove my exercise from firebase data
            self.ref?.child("Users").child(self.userID).child("MyExercises").child("My Exercise \(MyExIDList[indexPath.row])").setValue(nil)
            
            
            //remove name and id from lists
            MyExNameList.remove(at: indexPath.row)
            MyExIDList.remove(at: indexPath.row)
            
            self.myExercisesTableView.reloadData()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
