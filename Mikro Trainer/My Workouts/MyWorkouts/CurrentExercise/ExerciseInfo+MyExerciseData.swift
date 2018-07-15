//
//  ExerciseInfo+ExerciseData.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 7/15/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import Foundation


extension CurrentExerciseVC {
    
    
    //first check to see if the exercise lives within my exercises list and if so take data from there
    func getMyExerciseData(completion: @escaping ()->()) {
        self.ref?.child("Users/\(self.userID)/MyExercises/My Exercise \(self.exerciseID)").observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? NSDictionary{
                if let reps = dict["BaseReps"] as? String {
//                    print("reps my: \(reps)")
                    self.exerciseReps = Int(reps)!
                }
                if let sets = dict["BaseSets"] as? String {
//                    print("sets my: \(sets)")
                    self.exerciseSets = Int(sets)!
                }
                completion()
            }else{
                //never completed the workout before (not in list)
                self.getExcerciseData {
                completion()
                }
            }
        })
    }
    
    
    //get all exercise metadata from Exercises node if exercises arent existent within MyExercises list
    func getExcerciseData(completion: @escaping ()->()) {
        self.ref?.child("Exercises/\(self.exerciseID)").observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? NSDictionary{
                if let reps = dict["BaseReps"] as? String {
//                        print("reps: \(reps)")
                        self.exerciseReps = Int(reps)!
                    }
                    if let sets = dict["BaseSets"] as? String {
//                        print("sets: \(sets)")
                        self.exerciseSets = Int(sets)!
                    }
                
                completion()
            }else{
                //no response
                print("no response")
                completion()
            }
        })
        
    }
}
