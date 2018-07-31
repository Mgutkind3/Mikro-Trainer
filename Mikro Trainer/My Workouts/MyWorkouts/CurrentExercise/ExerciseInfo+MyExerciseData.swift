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
//                if let reps = dict["BaseReps"] as? String {
////                    print("reps my: \(reps)")
//                    self.exerciseReps = Int(reps)!
//                }
                if let sets = dict["BaseSets"] as? String {
//                    print("sets my from 1: \(sets)")
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
//                if let reps = dict["BaseReps"] as? String {
////                        print("reps: \(reps)")
//                        self.exerciseReps = Int(reps)!
//                    }
                    if let sets = dict["BaseSets"] as? String {
//                        print("sets from 2: \(sets)")
                        self.exerciseSets = Int(sets)!
                    }
                
                self.prevRepsList.removeAll()
                self.prevWeightList.removeAll()
                print("after remove all: \(self.prevRepsList.count)")
                completion()
            }else{
                //no response
                print("no response")
                completion()
            }
        })
        
    }


    //function to retrieve specific set placeholders
    func getSpecificRepsSetsData(completion: @escaping ()->()){
        self.prevRepsList.removeAll()
        self.prevWeightList.removeAll()
        self.ref?.child("Users/\(self.userID)/HistoricalExercises/Completed \(self.exerciseID)/\(self.mostRecentTimestamp)/sets_reps").observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? NSObject{
                if let obj = dict as? NSArray{
                    for key in obj {
                        if let spec = key as? NSDictionary{
                            self.prevRepsList.append(spec["reps"] as! String)
//                            print("reps: \(spec["reps"] as! String)")
                            self.prevWeightList.append(spec["weight"] as! String)
//                            print("weight: \(spec["weight"] as! String)")
                        }
//                        print("obj: \(key)")
                    }
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
