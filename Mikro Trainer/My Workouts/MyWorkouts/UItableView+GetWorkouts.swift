//
//  UItableView+MyExercises.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 6/24/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase


extension MyWorkoutsVC {
    
    
    //function to get list of my previous workouts
    func getAllMyWorkouts(userID:String, ref:DatabaseReference ,completion: @escaping ([String])->()){
        ref.child("Users/\(userID)/MyWorkouts").observeSingleEvent(of: .value, with: { snapshot in
            var list = [String]()
            list.append("Select the '+' sign to create a new workout")
            if let dict = snapshot.value as? NSDictionary{
                
                //add every workout to myPrevousWorkouts list and show in table
                for y in (dict) {
//                    self.myPreviousWorkouts.append(y.key as! String)
                    list.append(y.key as! String)
                    
                }
//                print("My workouts populated")
//                return self.myPreviousWorkouts
                completion(list)
            }else{
                //return cause the array was full of null values
//                print("my array not populated cause no 'MyWorkouts' found")
                completion(list)
            }
        })
    }
}
