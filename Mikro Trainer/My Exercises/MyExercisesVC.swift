//
//  MyExercisesVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 5/16/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit

class MyExercisesVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func addExcerciseButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddExcerciseVC") as! AddExcerciseVC
        navigationController?.pushViewController(vc, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
