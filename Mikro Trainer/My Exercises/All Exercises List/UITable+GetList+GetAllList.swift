//
//  UITable+GetList+GetAllList.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 6/25/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import Foundation


extension AllExercisesVC {
    
    //api call to get the list of ALL exercises
    func getListOfExercises(completion: @escaping ()->()){
        self.ref?.child("Exercises").observeSingleEvent(of: .value, with: { snapshot in
            //populate array with all exercise id's if value is not null. if null return and dont fail
            
            if let dict = snapshot.value as? [NSObject] {
                for y in (dict) {
                    let obj = y as? NSDictionary
                    if let exerciseID = obj?["ExerciseID"] as? String {
                        self.allExerciseIDList.append(exerciseID)
                    }
                    if let exerciseName = obj?["Name"] as? String {
                        self.allExerciseNameList.append(exerciseName)
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
    
    //fucntion to get the exercises in 'my' list
    func getMyList(completion: @escaping ()->()){
        self.ref?.child("Users/\(self.userID)/MyExercises").observeSingleEvent(of: .value, with: { snapshot in
            //populate array with all my exercises if value is not null. if null return and dont fail
            
            if let dict = snapshot.value as? NSDictionary{
                for y in (dict) {
                    
                    let obj = y.value as? NSDictionary
                    if let exerciseID = obj?["ExerciseID"] as? String {
                        self.myExerciseIDList.append(exerciseID)
                    }
                    if let exerciseName = obj?["Name"] as? String {
                        self.myExerciseNameList.append(exerciseName)
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
    
    //remove exercises from past and all when editing for a new workout
    func removeExerciseFromOtherLists(exerciseToRemove: String){
        //delete added item from table views so you cannot add it again
        var i = 0//index location
        print("exercise to remove is: \(exerciseToRemove)")
            //find the exercise in the other list and remove it
            for x in self.allExerciseIDList {
                if x == exerciseToRemove{
                    self.allExerciseIDList.remove(at: i)
                    self.allExerciseNameList.remove(at: i)
                }
                i = i + 1
            }
    
        var q = 0
            //find the exercise in the other list and remove it
            for x in self.myExerciseIDList {
                if x == exerciseToRemove{
                    self.myExerciseIDList.remove(at: q)
                    self.myExerciseNameList.remove(at: q)
                }
                q = q + 1
            }
        
        self.allExercisesTableView.reloadData()
    }
    
}//end of class


