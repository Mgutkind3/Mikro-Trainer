//
//  AllExercisesVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 5/17/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AllExercisesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var ref: DatabaseReference?
    var allExerciseIDList = [String]()
    var allExerciseName = [String]()
    var myExerciseIDList = [String]()
    var userID = String()
    @IBOutlet weak var allExercisesTableView: UITableView!
    
    //tells the table how many rows we need
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (allExerciseName.count)
    }
    
    //tells the prototype cell what is functions like
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = allExerciseName[indexPath.row]
        
        return cell
    }
    
    //returns the row that was selected and reacts somehow
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        let addAlert = UIAlertController(title: "Add New Exercise", message: "Would you like to add \(self.allExerciseName[indexPath.row]) to your exercise list?", preferredStyle: UIAlertControllerStyle.alert)
        
        addAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
//            self.addExerciseToMyExercises {
//                print("exercise added to my exercise")
//            }
        }))
        
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            addAlert.dismiss(animated: true, completion: nil)
        }))
        
        present(addAlert, animated: true, completion: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        userID = String(Auth.auth().currentUser!.uid)
        
        //function to get all exercises
        getListOfExercises {
            //logic to make one final list without already included exercises goes here.
            print("modifying list of workouts to add...")
            
            //create a list of exercises i already have
            for x in self.myExerciseIDList {
                if self.allExerciseIDList.contains(x){
                    //only display exercises that are not currently in MyExercises
                    let q = self.allExerciseIDList.index(of: x)!
                    self.allExerciseIDList.remove(at: q)
                    self.allExerciseName.remove(at: q)
                }
            }
            
            //reload table to refresh all the data
            self.allExercisesTableView.reloadData()
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //api call to get the list of exercises
    func getListOfExercises(completion: @escaping ()->()){
        self.ref?.child("Exercises").observeSingleEvent(of: .value, with: { snapshot in
            //populate array with all exercise id's if value is not null. if null return and dont fail
            
            if let dict = snapshot.value as? [NSObject] {
                for y in (dict) {
                    let obj = y as? NSDictionary
                    if let exerciseID = obj?["ExerciseID"] as? String {
//                        print("exercise name: \(exerciseID)")
                        self.allExerciseIDList.append(exerciseID)
                    }
                    if let exerciseName = obj?["Name"] as? String {
//                        print("exercise name: \(exerciseName)")
                        self.allExerciseName.append(exerciseName)
                    }
                }
                //do not complete this function until my list of exercises is already found
                self.getMyList {
                    print("My List: Obtained")
                    completion()
                }

            }else{
                //do not complete this function until my list of exercises is already found
                //return cause the array was full of null values
                self.getMyList {
                    print("My List: Obtained")
                    completion()
                }

            }
            
        })
    }
    
    //fucntion to get the exercises in my list
    func getMyList(completion: @escaping ()->()){
        self.ref?.child("Users/\(self.userID)/MyExercises").observeSingleEvent(of: .value, with: { snapshot in
            //populate array with all my exercises if value is not null. if null return and dont fail
            
            if let dict = snapshot.value as? NSDictionary{
                for y in (dict) {

                    let obj = y.value as? NSDictionary
                    if let exerciseID = obj?["ExerciseID"] as? String {
//                        print("exercise name: \(exerciseID)")
                        self.myExerciseIDList.append(exerciseID)
                        
                    }
                }
                print("MyExercises list populated")
                completion()
            }else{
                //return cause the array was full of null values
                print("my array not populated cause no 'MyExercises' found")
                completion()
            }

        })
    }
    

}
