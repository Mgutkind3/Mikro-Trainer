//
//  CurrentExerciseVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 7/7/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit

class CurrentExerciseVC: UIViewController {
    var exerciseTitle = ""
    var exerciseID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = exerciseTitle
        print("exerciseID: \(exerciseID)")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
