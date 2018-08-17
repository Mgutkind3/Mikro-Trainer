//
//  DetailsVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 8/17/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit

class DetailsVC: UIViewController {

    var exerciseTitle = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(exerciseTitle) Details"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
