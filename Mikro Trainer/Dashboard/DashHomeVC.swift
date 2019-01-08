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
    
    var exerciseNames = [String]()
    var exerciseDates = [String]()
    //translation dict from name to ID
    var idNameDict = [String:String]()
    //dictionary of ID to Dates completed
    var datesCompleted = [String:[String]]()
    var masterPicker = [[String]]()
    var currentExercise = String()
    
    
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
        self.selectionTextField.isEnabled = false
        
        //waiting for the list of hisroical exercises, id's and dates to come back
        self.getMyHistoricalExercises { nameList in
            self.exerciseNames = nameList
            print("picker exercise names", self.exerciseNames)
            //done getting historical exercises
            
            //0 case for picker
            self.currentExercise = self.exerciseNames[0]
            self.selectionTextField.isEnabled = true
            self.exercisePicker?.selectRow(0, inComponent: 0, animated: false)
            
            //update array with current dates they have been completed
            self.exerciseDates = self.datesCompleted[self.idNameDict[self.currentExercise]!]!
            self.exercisePicker?.reloadAllComponents()
            
            //https://medium.com/@smehta/ios-swift-creating-a-dynamic-picker-view-843b3290e7f0
            
        }
        
        //build the bar chart
        self.createBarChart()
    }
    
    //populate these with exercise information
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    //different arrays in the picker (multiple columns)
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        self.masterPicker.append(exerciseNames)
        //dont forget about a 0 case
        self.masterPicker.append(exerciseDates)
        
        if component == 0{
            return self.exerciseNames.count
        }else{
            return self.exerciseDates.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0{
            return self.exerciseNames[row]
        }else{
            return self.exerciseDates[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //if statement to change number of components in second column when first is changed
        self.currentExercise = masterPicker[0][pickerView.selectedRow(inComponent: 0)]
        self.exerciseDates = datesCompleted[idNameDict[self.currentExercise]!]!
        self.exercisePicker?.reloadAllComponents()
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
