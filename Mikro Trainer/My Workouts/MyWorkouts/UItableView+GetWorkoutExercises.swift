//
//  UItableView+GetWorkoutExercises.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 6/24/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import Foundation

extension WorkoutExercisesVC {
    
    //completion handler with parameter
    func getMyWorkoutExercises(completion: @escaping ()->(), workoutName: String){
        self.ref?.child("Users/\(self.userID)/MyWorkouts/\(workoutName)").observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? NSDictionary{
                
                //add exercise in workout & IDs to one list
                for y in (dict) {
                    let obj = y.value as? NSDictionary
                    if let exerciseID = obj?["ExerciseID"] as? String {
                        self.workoutExerciseIDs.append(exerciseID)
                        
                    }
                    if let exerciseName = obj?["Name"] as? String {
                        self.workoutExerciseNames.append(exerciseName)
                    }
                    
                }
                print("My workout exercises populated")
                completion()
            }else{
                //return cause the array was full of null values
                print("my array not populated cause no workout found")
                completion()
            }
        })
    }
}
