//
//  getRepsSets+Timespan.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 1/8/19.
//  Copyright © 2019 Michael Gutkind. All rights reserved.
//

import Foundation

extension DashHomeVC{
    
    //function to get the scheduled workouts from the database
    func getMyHistoricalRepsSets(completion: @escaping ([String],[Double],[Double],[Double])->()){
        self.ref?.child("Users/\(self.userID)/HistoricalExercises/\(self.fullIDSelected)/\(self.fullTimestampSelected)").observeSingleEvent(of: .value, with: { snapshot in
            //populate array with all my exercises if value is not null. if null return and dont fail
            var xSets = [String]()
            var wtVolume = [Double]()
            var wtPerSet = [Double]()
            var repsPerSet = [Double]()
            
            if let dict = snapshot.value as? NSDictionary{
//                print("dict ", dict)
                for x in dict{
                    if let objArr = x.value as? [NSObject]{
                        for yDict in objArr {
                            if let val = yDict as? NSDictionary{
                                if let weight = val["weight"] as? String {
//                                    print("weight: ", weight)
                                    if let reps = val["reps"] as? String {
//                                        print("reps: ", reps)
                                        if let set = val["set"] as? String {
//                                            print("set: ", set)
                                            wtPerSet.append(Double(weight)!)
                                            repsPerSet.append(Double(reps)!)
                                            let xVal = "Set \(set)"
                                            if let wtInt = Double(weight){
                                                if let repsInt = Double(reps){
                                                    let yVolumeWt = wtInt * repsInt
                                                    xSets.append(xVal)
                                                    wtVolume.append(yVolumeWt)
                                                }
                                            }
                                        }
                                    }

                                }
  
                                
                            }else{
                                print("not a dict")
                            }
                            
                        }
                    
                    }else{
                        print("nothing available")
                    }
                }
                completion(xSets, wtVolume, wtPerSet, repsPerSet)
            }else{
                //return cause the array was full of null values
                print("No Historical Exercises available")
                completion(xSets, wtVolume, wtPerSet, repsPerSet)
            }
        })
    }
    
    //function for parsing all of the days you workout
    func getTimeSpanSetsReps(completion: @escaping ([String],[Double],[Double],[Double])->()){
         self.ref?.child("Users/\(self.userID)/HistoricalExercises/\(self.fullIDSelected)/").observeSingleEvent(of: .value, with: { snapshot in
            
            var xSets = [String]()
            var wtVolume = [Double]()
            var wtPerSet = [Double]()
            var repsPerSet = [Double]()
            var setsList = [Int]()
            var counter = 0
            var dateCount = String()
            
             if let dict = snapshot.value as? NSDictionary{
                
                for date in dict {
                    if let dateDict = date.value as? NSDictionary{
//                        print("dict \(dateDict)")
                        for x in dateDict{
                            if let dateGuy = dateDict["Date"] as? String {
                                print("date guy:", dateGuy)
                                dateCount = dateGuy
                            }
                            if counter != 0 {
                                print("appending: ", counter)
                                setsList.append(counter)
                            }
                            //reset
                            counter = 0

                            if let objArr = x.value as? [NSObject]{
                                for yDict in objArr {
//                                    print("yDict: ",yDict)
                                    if let val = yDict as? NSDictionary{
                                        if let weight = val["weight"] as? String {
                                            //                                    print("weight: ", weight)
                                            if let reps = val["reps"] as? String {
                                                //                                        print("reps: ", reps)
                                                if let set = val["set"] as? String {
                                                    //                                            print("set: ", set)
                                                    counter = counter+1
                                                    wtPerSet.append(Double(weight)!)
                                                    repsPerSet.append(Double(reps)!)
                                                    let xVal = "Set \(set)"
                                                    if let wtInt = Double(weight){
                                                        if let repsInt = Double(reps){
                                                            let yVolumeWt = wtInt * repsInt
                                                            xSets.append(xVal)
                                                            wtVolume.append(yVolumeWt)
                                                        }
                                                    }
                                                }
                                            }
                                            
                                        }
                                        
                                        
                                    }else{
                                        print("not a dict")
                                    }
                                    
                                }
                                
                            }else{
                                print("nothing available")
                            }
                        }
                    }
                }
                //append the last element
                setsList.append(counter)
                print("sets list by date: ", setsList)
                completion(xSets, wtVolume, wtPerSet, repsPerSet)
             }else{
                print("could not get full time span reps")
                completion(xSets, wtVolume, wtPerSet, repsPerSet)
            }
            
        })
    }
    
}
