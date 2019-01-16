//
//  groupSearch+.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 1/15/19.
//  Copyright © 2019 Michael Gutkind. All rights reserved.
//

import Foundation
import Firebase

extension NewAccountVC{
    
    //uncomment line 197 in new account vc
    func findExistingGroups(email: String, completion: @escaping ()->()){
        let ogEmail = email.replacingOccurrences(of: ",", with: ".")
        //function to find any groups the new user is in
            self.ref?.child("Groups").observeSingleEvent(of: .value, with: { snapshot in

                var groupName = ""
                var groupID = ""
                var memberGroupID = ""
                
                if let dict = snapshot.value as? NSDictionary{
                    //append every group the user is a part of
                    for y in (dict) {
//                        print("Group: ", y.key)
                        //reset values and submit finished values to datase
                        if groupName != "" && groupID != "" && memberGroupID != ""{
                            
                            //set up groups in user's database
                            self.ref?.child("Users").child(self.userID).child("Groups").child(groupID).child(memberGroupID).setValue(groupName)
                            //reset values to null
                            groupName = ""
                            groupID = ""
                            memberGroupID = ""
                        }
                        if let groupValue =  y.value as? NSDictionary{
                            for key in groupValue{
                                //get member id and group id
                                if key.key as! String == "Members"{
                                    //inside members
                                    if let members = key.value as? NSDictionary{
                                        for member in members {
                                            //match user to rights on the group members
                                            if member.value as! String ==  ogEmail{
                                                
                                                groupID = y.key as! String
                                                memberGroupID = member.key as! String
                                                
                                                print("group id: ", groupID)
                                                print("member group id: ", memberGroupID)
                                                
                                            }
                                        
                                        }
                                    }
                                }
                                //get group actual name
                                if key.key as! String == "Info"{
                                    if let info = key.value as? NSDictionary{
                                        for name in info{
                                            if name.key as! String == "GroupName"{
                                                groupName = name.value as! String
                                                
                                                print("name: ", name.value)
                                            }
                                            
                                        }
                                    }
                                }
                                
                            }
                            
                        }
                        
                    }
                    if groupName != "" && groupID != "" && memberGroupID != ""{
                        
                        //set up groups in user's database
                        self.ref?.child("Users").child(self.userID).child("Groups").child(groupID).child(memberGroupID).setValue(groupName)

                    }
                    completion()
                }else{
                    //return cause the array was full of null values
                    print("No Group members Found")
                    completion()
                }
            })
        
    }
    
    
}
