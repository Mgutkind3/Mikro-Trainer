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

class AllExercisesVC: UIViewController {
    var ref: DatabaseReference?
    var allExerciseIDList = [String]()
    var allExerciseName = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        //function to get all exercises
        getListOfExercises {
            print("testing")
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
                        print("exercise name: \(exerciseID)")
                        self.allExerciseIDList.append(exerciseID)
                    }
                    if let exerciseName = obj?["Name"] as? String {
                        print("exercise name: \(exerciseName)")
                        self.allExerciseName.append(exerciseName)
                    }
                }
                completion()
            }else{
                //return cause the array was full of null values
                completion()
            }
            
        })
    }
    
//    func getMyList
    

}
