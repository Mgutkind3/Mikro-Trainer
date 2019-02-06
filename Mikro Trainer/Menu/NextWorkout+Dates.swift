//
//  NextWorkout+Dates.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 1/5/19.
//  Copyright © 2019 Michael Gutkind. All rights reserved.
//

import Foundation


extension MainMenu{
    
    //function to get the scheduled workouts from the database
    func getNextWorkouts(completion: @escaping (String, String)->()){
        self.ref?.child("Users/\(self.userID)/ScheduledWorkouts").observeSingleEvent(of: .value, with: { snapshot in
            //populate array with all my exercises if value is not null. if null return and dont fail
            var scheduledWorkouts = [String]()
            var scheduleDict = [String:String]()
            var workoutName = ""
            
            if let dict = snapshot.value as? NSDictionary{
                scheduleDict = dict as! [String : String]
                for x in dict {
                    //just the date
                    scheduledWorkouts.append(x.key as! String)
                }

                
                print("workout schedule populated")
                let nextWorkout = self.closestWorkout(dates: scheduledWorkouts)
                
                workoutName = scheduleDict[nextWorkout.replacingOccurrences(of: "/", with: "-")] ?? ""
                
                completion(nextWorkout, workoutName)
                
            }else{
                //return cause the array was full of null values
                print("workout schedule not populated")
                completion("No Workout Available", workoutName)
            }
        })
    }
    
    func closestWorkout(dates: [String])->(String){
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MM-dd-yyyy"
        var closestDate = Date()
        let now = Date()//todays date
        var datesList = [Date]()
        var closeDate = String()
        
        //go through array and compare dates, keeping the most recent one
        for x in dates{
            if let date = dateFormatterGet.date(from: x) {
                datesList.append(date)
            } else {
                print("There was an error decoding the string")
            }
        }
        datesList = datesList.sorted()
        for x in datesList {
            if x > now{
                closestDate = x
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                formatter.timeZone = Calendar.current.timeZone
                closeDate = formatter.string(from: closestDate)
                break
            }else{
                closeDate = "No workouts available"
            }
        }
        

        return closeDate
    }
    
    
    
    
}
