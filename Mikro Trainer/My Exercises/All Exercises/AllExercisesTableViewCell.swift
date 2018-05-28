//
//  AllExercisesTableViewCell.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 5/27/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit

class AllExercisesTableViewCell: UITableViewCell {

    @IBOutlet weak var addExerciseButton: UIButton!
    @IBOutlet weak var cellHeaderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
