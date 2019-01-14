//
//  GroupWorkouts+.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 1/14/19.
//  Copyright © 2019 Michael Gutkind. All rights reserved.
//

import Foundation
import Firebase


extension MyWorkoutsVC {
    
    //function to get list of my previous workouts
    func getAllMyGroupWorkouts(userID:String, ref:DatabaseReference, groupID: String, completion: @escaping ([String])->()){
        ref.child("Groups/\(groupID)/GroupWorkouts").observeSingleEvent(of: .value, with: { snapshot in
            var list = [String]()
            list.append("Select the '+' sign to create a new workout")
            if let dict = snapshot.value as? NSDictionary{
                
                //add every workout to myPrevousWorkouts list and show in table
                for y in (dict) {
//                    print("y key:", y.key)
                    //                    self.myPreviousWorkouts.append(y.key as! String)
                    list.append(y.key as! String)
                    
                }
                completion(list)
            }else{
                print("my array not populated cause no 'MyWorkouts' found")
                completion(list)
            }
        })
    }

}

