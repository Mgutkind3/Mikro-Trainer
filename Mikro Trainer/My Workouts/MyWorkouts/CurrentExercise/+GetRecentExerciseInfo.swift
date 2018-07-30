//
//  +GetRecentExerciseInfo.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 7/29/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import Foundation


extension CurrentExerciseVC{
    
    //function to get the latest exercise
    func getMostRecentExercise(completion: @escaping ()->()){
        var listOfDates = [Date]()
        self.ref?.child("Users/\(self.userID)/HistoricalExercises/Completed \(self.exerciseID)").observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? NSDictionary{
                
                //add every workout to myPrevousWorkouts list and show in table
                for y in (dict) {
                    listOfDates.append(makeDate(timestampString: y.key as! String))
                }
                
                let mostRecentDate = biggestDate(listOfTimestamps: listOfDates )
//                print("most recent date: \(mostRecentDate)")//working
                self.mostRecentTimestamp = mostRecentDate
                completion()
            }else{
                //return cause there was no recorded past exercise
                print("Exercise never completed in the past")
                completion()
            }
        })
    }
}

//http://userguide.icu-project.org/formatparse/datetime
//convert timestamp to date
func makeDate(timestampString: String) -> Date {
    let dateFormatter = DateFormatter()
    
    print("making date")
    dateFormatter.dateFormat = "M-d-yyyy:H:m:s"
    dateFormatter.timeZone = TimeZone.current
    guard let date = dateFormatter.date(from: timestampString) else {
        fatalError("ERROR: Date conversion failed due to mismatched format.")
    }
    print("Post converted date: \(date)")
    return date
}

//find the most recent(biggest) date
func biggestDate(listOfTimestamps: [Date])->(String){
    let formatter = DateFormatter()
    formatter.dateFormat = "M-d-yyyy:H:m:s"
    var mostRecentDate = formatter.date(from: "1-1-1900:1:1:1")!
    
    for x in listOfTimestamps{
        if x > mostRecentDate{
            mostRecentDate = x
        }
    }
    
    //convert data to database timestamp format
    formatter.dateFormat = "yyyy-M-d H:m:s"
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    formatter.string(from: mostRecentDate)
    
    let dt = formatter.date(from: formatter.string(from: mostRecentDate))
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "M-d-yyyy:H:m:s"
    
    //returns in format that it is stored in the database
    return formatter.string(from: dt!)
}
