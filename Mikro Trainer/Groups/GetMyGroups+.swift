//
//  GetMyGroups+.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 1/14/19.
//  Copyright © 2019 Michael Gutkind. All rights reserved.
//

import Foundation
import Firebase

extension GroupsMenuVC {
    
    
    //function to get list of my previous workouts
    func getAllMyGroups(completion: @escaping ([String], [String], [String])->()){
        self.ref?.child("Users/\(self.userID)/Groups").observeSingleEvent(of: .value, with: { snapshot in
            var listOfGroups = [String]()
            var listOfMemberIDs = [String]()
            var groupIDs = [String]()
            if let dict = snapshot.value as? NSDictionary{
                //append every group the user is a part of
                for y in (dict) {
//                    print("y key: ", y.key)
                    groupIDs.append(y.key as! String)
                    if let title = y.value as? NSDictionary{
                        for x in title{
                            listOfGroups.append(x.value as! String)
                            listOfMemberIDs.append(x.key as! String)
                            
                        }
                        
                    }

                }
                completion(listOfGroups, listOfMemberIDs, groupIDs)
            }else{
                //return cause the array was full of null values
                print("No Groups Found")
                completion(listOfGroups, listOfMemberIDs, groupIDs)
            }
        })
    }
    
    
}
