//
//  MemberCell.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 1/15/19.
//  Copyright © 2019 Michael Gutkind. All rights reserved.
//

import UIKit

class MemberCell: UITableViewCell {


    @IBOutlet weak var cellTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
