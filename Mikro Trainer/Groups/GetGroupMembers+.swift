//
//  GetGroupMembers+.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 1/15/19.
//  Copyright © 2019 Michael Gutkind. All rights reserved.
//

import Foundation
import Firebase

extension AddGroupMembersVC{
    
    //function to get list of my previous workouts
    func getAllMyGroupMembers(completion: @escaping ([String])->()){
        self.ref?.child("Groups/\(self.groupID)/Members").observeSingleEvent(of: .value, with: { snapshot in
            var groupMembers = [String]()
            if let dict = snapshot.value as? NSDictionary{
                //append every group the user is a part of
                for y in (dict) {
                    groupMembers.append(y.value as! String)
                
                }
                completion(groupMembers)
            }else{
                //return cause the array was full of null values
                print("No Group members Found")
                completion(groupMembers)
            }
        })
    }
    
    
}

