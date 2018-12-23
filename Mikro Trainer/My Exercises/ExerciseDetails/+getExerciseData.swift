//
//  +getExerciseData.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 12/23/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import Foundation

extension DetailsVC {
    
    //api call to get the list of ALL exercises
    func getListOfExerciseDetails(completion: @escaping ()->()){
        self.ref?.child("Exercises/\(self.exerciseID)").observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? NSDictionary {
                self.detailsDict = dict as! [String : String]
                completion()
            }else{
                //Could not find details for designated exercise
                print("nothing")
                completion()
            }
        })
    }

}//end of class
