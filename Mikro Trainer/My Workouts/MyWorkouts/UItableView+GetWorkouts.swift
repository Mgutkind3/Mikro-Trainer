//
//  UItableView+MyExercises.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 6/24/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import Foundation


extension MyWorkoutsVC {
    
    
    //function to get list of my previous workouts
    func getAllMyWorkouts(completion: @escaping ()->()){
        self.ref?.child("Users/\(self.userID)/MyWorkouts").observeSingleEvent(of: .value, with: { snapshot in
            
            if let dict = snapshot.value as? NSDictionary{
                
                //add every workout to myPrevousWorkouts list and show in table
                for y in (dict) {
                    self.myPreviousWorkouts.append(y.key as! String)
                }
                print("My workouts populated")
                completion()
            }else{
                //return cause the array was full of null values
                print("my array not populated cause no 'MyWorkouts' found")
                completion()
            }
        })
    }
}
