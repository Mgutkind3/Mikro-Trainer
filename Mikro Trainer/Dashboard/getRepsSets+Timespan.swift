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
    func getTimeSpanSetsReps(completion: @escaping ([String],[Double],[Double],[Double],[Int])->()){
         self.ref?.child("Users/\(self.userID)/HistoricalExercises/\(self.fullIDSelected)/").observeSingleEvent(of: .value, with: { snapshot in
            
            //x axis
            var xSets = [String]()
            //y axis's
            var wtVolume = [Double]()
            var wtVolumePerSet = [[Double]]()
            var wtTmp = [Double]()
            
            //different data for wt lifted
            var wtPerSet = [Double]()
            var totalWtPerSet = [[Double]]()
            var totalWtTmp = [Double]()
            
            //different data for wt lifted
            var repsPerSet = [Double]()
            var totalRepsPerSet = [[Double]]()
            var totalRepsTmp = [Double]()
            
            //count number of sets
            var setsList = [Int]()
            var counter = 0
            
            var datesStringTyp = [String]()

            
             if let dict = snapshot.value as? NSDictionary{
                
                for date in dict {
                    //current date in loop
                    datesStringTyp.append(date.key as! String)
                    if let dateDict = date.value as? NSDictionary{
//                        print("dict \(dateDict)")
                        for x in dateDict{
                            if counter != 0 {
//                                print("appending: ", counter)
                                setsList.append(counter)
                                wtVolumePerSet.append(wtTmp)
                                totalWtPerSet.append(totalWtTmp)
                                totalRepsPerSet.append(totalRepsTmp)
                            }
                            //reset
                            wtTmp.removeAll()
                            totalWtTmp.removeAll()
                            totalRepsTmp.removeAll()
                            
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
//                                                    wtPerSet.append(Double(weight)!)
                                                    totalWtTmp.append(Double(weight)!)
//                                                    repsPerSet.append(Double(reps)!)
                                                    totalRepsTmp.append(Double(reps)!)
                                                    let xVal = "Set \(set)"
                                                    if let wtInt = Double(weight){
                                                        if let repsInt = Double(reps){
                                                            let yVolumeWt = wtInt * repsInt
                                                            xSets.append(xVal)
//                                                            wtVolume.append(yVolumeWt)
                                                            wtTmp.append(yVolumeWt)
                                                            
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
                wtVolumePerSet.append(wtTmp)
                totalWtPerSet.append(totalWtTmp)
                totalRepsPerSet.append(totalRepsTmp)
//                print("sets list by date: ", setsList)
//                print("each set in a 2 dimensional array: ", wtVolumePerSet ) //working
                (wtVolume, wtPerSet, repsPerSet, setsList) = self.convertStringToDate(stringList: datesStringTyp, VolumeLifted: wtVolumePerSet, wtLifted: totalWtPerSet, repsLifted: totalRepsPerSet, setAmount: setsList )
                
//                print("SETS LIST: ", setsList)
                completion(xSets, wtVolume, wtPerSet, repsPerSet, setsList)
             }else{
                print("could not get full time span reps")
                completion(xSets, wtVolume, wtPerSet, repsPerSet, setsList)
            }
            
        })
    }
 
    
    
    //convert list of strings to dates and sort them
    func convertStringToDate(stringList: [String], VolumeLifted: [[Double]], wtLifted:[[Double]], repsLifted:[[Double]], setAmount: [Int])->([Double],[Double],[Double],[Int]){
        var dateList = [Date]()
        //dictionary of dates copleted along with their sets
        //weight volume
        var weightDict = [Date:[Double]]()
        var weightLiftDict = [Date:[Double]]()
        var repsDict = [Date:[Double]]()
        var setsAmtDict = [Date:Int]()
        
        var sortedSetsWeightVol = [Double]()
        var sortedSetsWeightLifted = [Double]()
        var sortedSetsTotalReps = [Double]()
        var setsRightOrder = [Int]()
        //convert to date so the list can be sorted
        for x in stringList{
            formatter.dateFormat = "M-d-yyyy:H:m:s"
            formatter.timeZone = Calendar.current.timeZone //this timezone will print wrong (one less) but store right
            let date = formatter.date(from:x)!
            dateList.append(date)
        }
        
        var i = 0
        for x in dateList{
            weightDict[x] = VolumeLifted[i]
            weightLiftDict[x] = wtLifted[i]
            repsDict[x] = repsLifted[i]
            setsAmtDict[x] = setAmount[i]
            i = i + 1
        }
        
        let sortedKeys = Array(weightDict.keys).sorted() // sorts the keys only

        //re order all the data
        for x in sortedKeys{
            sortedSetsWeightVol = sortedSetsWeightVol + weightDict[x]!
            sortedSetsWeightLifted = sortedSetsWeightLifted + weightLiftDict[x]!
            sortedSetsTotalReps = sortedSetsTotalReps + repsDict[x]!
            setsRightOrder.append(setsAmtDict[x]!)
            
        }
        
//        print("final sorted sets: ", setsRightOrder)
        
        return (sortedSetsWeightVol, sortedSetsWeightLifted , sortedSetsTotalReps, setsRightOrder)
    }
    
    
    
    
}
