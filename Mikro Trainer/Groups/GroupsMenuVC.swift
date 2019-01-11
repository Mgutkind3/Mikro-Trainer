//
//  GroupsMenuVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 1/11/19.
//  Copyright © 2019 Michael Gutkind. All rights reserved.
//

import UIKit

class GroupsMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var groupList = [String]()//get this data from firebase

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Your Groups"

        // Do any additional setup after loading the view.
    }
    
    //bring me to a page that lets me create a group
    @IBAction func createNewGroupBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewGroupVC") as! NewGroupVC
        //Change name of back button
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem // This will show in the next view
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let groupCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "GroupCell")
        
        return groupCell
    }

}
