//
//  DashHomeVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 12/27/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit
import SwiftCharts
import Firebase

class DashHomeVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    

    var chartView: BarsChart!
    private var exercisePicker: UIPickerView?
    @IBOutlet weak var selectionTextField: UITextField!
    
    //database credentials
    var userID = String()
    var ref: DatabaseReference?
    
    //    pod 'SwiftCharts'
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //weight picker view
        exercisePicker = UIPickerView()
        exercisePicker?.delegate = self
        exercisePicker?.dataSource = self
        selectionTextField.inputView = exercisePicker
        self.hideKeyboardWhenTappedAround()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //get user id
        self.ref = Database.database().reference()
        self.userID = String(Auth.auth().currentUser!.uid)
        
        self.getMyHistoricalExercises {
            //done getting historical exercises
        }
        
        //build the bar chart
        self.createBarChart()
    }
    
    //populate these with exercise information
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
    
    func createBarChart(){
        let chartConfig = BarsChartConfig(valsAxisConfig: ChartAxisConfig(from: 0, to: 800, by: 100))
        
        let frame = CGRect(x: 0, y:200, width: self.view.frame.width, height: 450)
        
        let chart = BarsChart(
            frame: frame,
            chartConfig: chartConfig,
            xTitle: "Months",
            yTitle: "Units Sold",
            bars: [
                ("Jan", 120),
                ("Feb", 400.5),
                ("Mar", 100),
                ("Apr", 500.4),
                ("May", 160.8),
                ("Jun", 100.5),
                ("Jul", 200),
                ("Aug", 180.5),
                ("Sep", 334),
                ("Oct", 156.4),
                ("Nov", 667.8),
                ("Dec", 178.5)
            ],
            color: UIColor.darkGray,
            barWidth: 15
        )
        
        self.view.addSubview(chart.view)
        self.chartView = chart
    }
    


}
