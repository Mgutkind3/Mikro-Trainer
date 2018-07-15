//
//  WIPExerciseCell.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 7/15/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit

protocol CellCheckDelegate {
    func checkWeightValidity()
    func deactivateSave()
}

class WIPExerciseCell: UITableViewCell {
    @IBOutlet weak var setLabel: UILabel!
    @IBOutlet weak var setTxtField: UITextField!
    var delegate: CellCheckDelegate?
    
    @IBOutlet weak var repsTxtField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func repsEditingStarted(_ sender: Any) {
        delegate?.deactivateSave()
    }
    
    @IBAction func repsEditingEnded(_ sender: Any) {
        self.delegate?.checkWeightValidity()
    }
    
    @IBAction func editingStartedAction(_ sender: Any) {
        delegate?.deactivateSave()
    }
    
    @IBAction func editingEndedAct(_ sender: Any) {
        self.delegate?.checkWeightValidity()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }

}
