//
//  DashHomeVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 12/27/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit
import Charts

class DashHomeVC: UIViewController {

    
    @IBOutlet weak var lineChartView: LineChartView!
    //    pod 'Charts'
    override func viewDidLoad() {
        super.viewDidLoad()
        setChartValues()
        self.navigationItem.title = "Preformance"

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func setChartBtn(_ sender: Any) {
        let count = Int(arc4random_uniform(20) + 3)
        setChartValues(count: count)
    }
    
    func setChartValues(count: Int=20){
        let values = (0..<count).map { (i) -> ChartDataEntry in
            let val = Double(arc4random_uniform(UInt32(count)) + 3)
            return ChartDataEntry(x: Double(i), y: val)
        }
        
        let set1 = LineChartDataSet(values: values, label: "DataSet 1")
        let data = LineChartData(dataSet: set1)
        
        self.lineChartView.data = data
        
    }


}
