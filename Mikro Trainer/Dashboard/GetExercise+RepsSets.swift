//
//  GetExercise+RepsSets.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 1/7/19.
//  Copyright © 2019 Michael Gutkind. All rights reserved.
//

import Foundation

extension DashHomeVC {
    
    //function to get the scheduled workouts from the database
    func getMyHistoricalExercises(completion: @escaping ([String])->()){
        self.ref?.child("Users/\(self.userID)/HistoricalExercises").observeSingleEvent(of: .value, with: { snapshot in
            //populate array with all my exercises if value is not null. if null return and dont fail
            var fullIDs = [String]()
            var exerciseNames = [String]()
            
            if let dict = snapshot.value as? NSDictionary{
                for x in dict{
                    fullIDs.append(x.key as! String)
//                    prinst("x key: ", x.key)
                    if let val = x.value as? NSDictionary{
//                        print("sval keys is: ", val.allKeys)
                        //populate new dictionary of dates completed
                        self.datesCompleted[x.key as! String] = (val.allKeys as! [String])
                    }else{
                        print("val cannot be dictionary")
                    }
                    
                    //logic to individually get each unique id name //do in a different file
                }
                
                //function to seperate id from word "completed"
                self.getIDFromName(uniqueIDList: fullIDs
                    , completion: { nameList in
//                        print("exercise Names: ", exerciseNames)
                        exerciseNames = nameList
                        completion(exerciseNames)
                })
                
            }else{
                //return cause the array was full of null values
                print("No Historical Exercises available")
                completion(exerciseNames)
            }
        })
    }
    
    //function to seperate word from uniqueID in historical exercises
    func getIDFromName (uniqueIDList: [String], completion: @escaping ([String])->()){
        var exerciseIDs = [String]()
        var exerciseNames = [String]()
        
        //seperate words from unique ID
        for x in uniqueIDList{
            if x.contains(" "){
                let splitItems = x.split(separator: " ", maxSplits: 1)
                exerciseIDs.append(String(splitItems[1]))
            }else{
                print("doesnt have  unique number")
            }
        }
        
        //match unique id to exercise name
         self.getNameFromID(exerciseIDs: exerciseIDs) { nameList in
            exerciseNames = nameList
            completion(exerciseNames)
            
        }
       
    }
    
    //function that queries the exercises branch and matches the na,e to uniqueID
    func getNameFromID(exerciseIDs: [String], completion: @escaping ([String])->()){
        self.ref?.child("Exercises").observeSingleEvent(of: .value, with: { snapshot in
            var exerciseNames = [String]()
            
            if let dict = snapshot.value as? [NSObject] {
                for y in (dict) {
//                    print("y: ", y)
                    let obj = y as? NSDictionary
                    if let exerciseID = obj?["ExerciseID"] as? String {
                        if let exerciseName = obj?["Name"] as? String {
                            
                            //if my array contains an exercise id then append the value
                            if exerciseIDs.contains(exerciseID){
                                exerciseNames.append(exerciseName)
                                self.idNameDict[exerciseName] = "Completed \(exerciseID)"
                            }
                        }
                    }

                }

                completion(exerciseNames)
            }else{
                print("not available to match name and ID")
                completion(exerciseNames)
            }
            
            
        })
    }
    
    
}
