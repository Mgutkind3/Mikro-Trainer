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
    func getMyHistoricalExercises(completion: @escaping ()->()){
        self.ref?.child("Users/\(self.userID)/HistoricalExercises").observeSingleEvent(of: .value, with: { snapshot in
            //populate array with all my exercises if value is not null. if null return and dont fail
            
//            print("snapshot: ", snapshot)
            if let dict = snapshot.value as? NSDictionary{
                
                print(dict)
                print("Historical exercises available")
                completion()
            }else{
                //return cause the array was full of null values
                print("No Historical Exercises available")
                completion()
            }
        })
    }
    
}
