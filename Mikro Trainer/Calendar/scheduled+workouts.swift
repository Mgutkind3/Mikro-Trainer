//
//  scheduled+workouts.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 1/5/19.
//  Copyright © 2019 Michael Gutkind. All rights reserved.
//

import Foundation

extension CalendarHomeVC{
    
    
    //function to get the scheduled workouts from the database
    func getMyScheduledWorkouts(completion: @escaping ()->()){
        self.ref?.child("Users/\(self.userID)/ScheduledWorkouts").observeSingleEvent(of: .value, with: { snapshot in
            //populate array with all my exercises if value is not null. if null return and dont fail
            
            if let dict = snapshot.value as? NSDictionary{
                
                self.workoutDict = dict as! [String : String]
                print("workout schedule populated")
                completion()
            }else{
                //return cause the array was full of null values
                print("workout schedule not populated")
                completion()
            }
        })
    }
    
}
