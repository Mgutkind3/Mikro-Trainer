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
import Charts

class DashHomeVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var chartView: BarsChart!
    @IBOutlet weak var barChartView: BarChartView!
    
    @IBOutlet weak var xAxisSets: UILabel!
    @IBOutlet weak var yAxisVolumeLifted: UILabel!
    var exerciseNames = [String]()
    var exerciseDates = [String]()
    var exerciseDatesClean = [String]()
    //translation dict from name to ID
    var idNameDict = [String:String]()
    //translation dict from ID tp name
    var nameIDDict = [String:String]()
    //dictionary of ID to Dates completed
    var datesCompleted = [String:[String]]()
    var currentExercise = String()
    
    //bar chart data
    var barChart = [(String(),Double())]
    
    //keep keys in a variable
    var fullTimestampSelected = String()
    var fullIDSelected = String()
    
    private var exercisePicker: UIPickerView?
    @IBOutlet weak var selectionTextField: UITextField!
    
    //database credentials
    var userID = String()
    var ref: DatabaseReference?
    
    //date format variables
    let formatter = DateFormatter()
    
    //    pod 'SwiftCharts'
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.yAxisVolumeLifted.transform = s
        //weight picker view
        exercisePicker = UIPickerView()
        exercisePicker?.delegate = self
        exercisePicker?.dataSource = self
        selectionTextField.inputView = exercisePicker
        
        //bar chart data
        self.barChartView.noDataText = "Choose a workout and date above"

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //get user id
        self.ref = Database.database().reference()
        self.userID = String(Auth.auth().currentUser!.uid)
        self.selectionTextField.isEnabled = false
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        let vButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(getBarChartData))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil);
        let cButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: nil, action: #selector(cancelBtn));
        toolBar.setItems([vButton, flexibleSpace, cButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.selectionTextField.inputAccessoryView = toolBar
        
        //waiting for the list of hisroical exercises, id's and dates to come back
        self.getMyHistoricalExercises { nameList in
            if nameList.count != 0{
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
            self.exerciseDatesClean = self.cleanUpDates(dates: self.exerciseDates)
            self.exerciseDatesClean.insert("All Dates", at: 0)
            self.exerciseDates.insert("All Dates", at: 0)
            
            
            //set 0 case
            self.fullTimestampSelected = self.exerciseDates[0] //will be "all dates"
            self.fullIDSelected = self.idNameDict[self.exerciseNames[0]]!
            self.selectionTextField.text = "\(self.currentExercise) on \(self.exerciseDatesClean[0])"
            self.selectionTextField.placeholder = "Choose an Exercise and Date"
            //build the graph initially
            self.getBarChartData()
            
            //https://medium.com/@smehta/ios-swift-creating-a-dynamic-picker-view-843b3290e7f0
            }else{
                self.selectionTextField.isEnabled = false
                self.barChartView.noDataText = "Complete an exercise for the data to be displayed"
            }
        }
    }
    
    //function to retrieve sets and reps data and display them
    @objc func getBarChartData(){
        
        print("full id: ", self.fullIDSelected)
        print("timestamps: ", self.fullTimestampSelected)
        
        if self.fullTimestampSelected == "All Dates" {
            print("ALL Dates")
            self.barChartView.clear()
            
            //get a full history
            self.getTimeSpanSetsReps{ xSets, yVolume in
                //build the bar chart
                self.setChart(dataPoints: xSets, values: yVolume)
                
            }
        }else{
        
        //get the sets and reps data to be displayed
        self.getMyHistoricalRepsSets { xSets, yVolume in
            //build the bar chart
            self.setChart(dataPoints: xSets, values: yVolume)
            //done getting reps data for bar graph
            }
        }
        self.dismissKeyboard()
    }
    
    //cancel action
    @objc func cancelBtn(){
        self.dismissKeyboard()
    }
    
    //populate these with exercise information
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    //different arrays in the picker (multiple columns)
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0{
            return self.exerciseNames.count
        }else{
            return self.exerciseDatesClean.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0{
            return self.exerciseNames[row]
        }else{
            return self.exerciseDatesClean[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        //resetn component 2 to first one in index
        if component == 0{
            self.exercisePicker?.selectRow(0, inComponent: 1, animated: false)
        }
        //if statement to change number of components in second column when first is changed
        self.currentExercise = exerciseNames[pickerView.selectedRow(inComponent: 0)]
        self.exerciseDates = datesCompleted[idNameDict[self.currentExercise]!]!
        self.exerciseDatesClean = self.cleanUpDates(dates: self.exerciseDates)
        //for retrieving all the dates at once
        self.exerciseDatesClean.insert("All Dates", at: 0)
        self.exerciseDates.insert("All Dates", at: 0)
        self.exercisePicker?.reloadAllComponents()
        let dateSelected = exerciseDatesClean[pickerView.selectedRow(inComponent: 1)]
        self.selectionTextField.text = "\(self.currentExercise) on \(dateSelected)"
        
        self.fullTimestampSelected = self.exerciseDates[pickerView.selectedRow(inComponent: 1)]
        self.fullIDSelected = self.idNameDict[self.currentExercise]!
    }
    
    //make dates look presentable to the people chosing them
    func cleanUpDates(dates: [String])->([String]){
        var refinedDates = [String]()
        for x in dates {
        
//            "\(month)-\(day)-\(year):\(hour):\(minute):\(second)"
            formatter.dateFormat = "MM-dd-yyyy:H:m:s"
            formatter.timeZone = Calendar.current.timeZone //this timezone will print wrong (one less) but store right
            let date = formatter.date(from:x)!
            formatter.dateFormat = "MM-dd-yyy"
            let refurbishedDate = formatter.string(from: date)
            refinedDates.append(refurbishedDate)
            
        }
        
        return refinedDates
    }
    
    //https://github.com/AshishKapoor/cex-graphs/blob/master/cex-graphs/CGMainViewController.swift
    //trying this chart now
    func setChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), yValues: [values[i]])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Weights Lifted")
        let chartData = BarChartData(dataSet: chartDataSet)

        barChartView.data = chartData
        
//        barChartView.
        barChartView.xAxis.labelCount = dataPoints.count
        barChartView.xAxis.labelTextColor = UIColor.black
        
    }
    
    //not using below function right now.
    func createBarChart(){
        let chartConfig = BarsChartConfig(valsAxisConfig: ChartAxisConfig(from: 0, to: 800, by: 100))
        
        let frame = CGRect(x: 0, y:200, width: self.view.frame.width, height: 450)
        
        let chart = BarsChart(
            frame: frame,
            chartConfig: chartConfig,
            xTitle: "Sets",
            yTitle: "Volume of Weight Lifted",
            bars: self.barChart,
            color: UIColor.darkGray,
            barWidth: 15
        )
        
        self.view.addSubview(chart.view)
        self.chartView = chart
    }
    


}
