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
    
    @IBOutlet weak var barChartView: BarChartView!
    
    @IBOutlet weak var repsBarChart: BarChartView!
    @IBOutlet weak var xAxisSets: UILabel!
    
    @IBOutlet weak var weightBarChart: BarChartView!
    @IBOutlet weak var wtYAxis: UILabel!
    @IBOutlet weak var repsYAxis: UILabel!
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
    
    //list of how bars are broken up
    var setLists = [Int]()
    
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
        self.navigationItem.title = "Performance"
        
        self.yAxisVolumeLifted.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        self.repsYAxis.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        self.wtYAxis.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        //weight picker view
        exercisePicker = UIPickerView()
        exercisePicker?.delegate = self
        exercisePicker?.dataSource = self
        selectionTextField.inputView = exercisePicker
        
        //bar chart data
        self.barChartView.noDataText = "Choose a workout and date above"
        //set description to null
        self.barChartView.chartDescription?.text = ""
        self.barChartView.xAxis.labelPosition = .bottom
        self.barChartView.rightAxis.enabled = false
        self.barChartView.highlighter = nil
        self.barChartView.doubleTapToZoomEnabled = false
        self.barChartView.pinchZoomEnabled = true
        self.barChartView.legend.enabled = false
        
        //weight chart data
        self.weightBarChart.noDataText = "Choose a workout and date above"
        //set description to null
        self.weightBarChart.chartDescription?.text = ""
        self.weightBarChart.xAxis.labelPosition = .bottom
        self.weightBarChart.rightAxis.enabled = false
        self.weightBarChart.highlighter = nil
        self.weightBarChart.doubleTapToZoomEnabled = false
        self.weightBarChart.pinchZoomEnabled = true
        self.weightBarChart.legend.enabled = false
        
        //reps chart data
        self.repsBarChart.noDataText = "Choose a workout and date above"
        //set description to null
        self.repsBarChart.chartDescription?.text = ""
        self.repsBarChart.xAxis.labelPosition = .bottom
        self.repsBarChart.rightAxis.enabled = false
        self.repsBarChart.highlighter = nil
        self.repsBarChart.doubleTapToZoomEnabled = false
        self.repsBarChart.pinchZoomEnabled = true
        self.repsBarChart.legend.enabled = false
        
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInOutQuart)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //get user id
        self.ref = Database.database().reference()
        self.userID = String(Auth.auth().currentUser!.uid)
        self.selectionTextField.isEnabled = false
//        self.exerciseNames.removeAll()
//        self.exerciseDates.removeAll()
//        self.exerciseDatesClean.removeAll()
        
        
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
            //reorder the dates so that they are in chronological order
            (self.exerciseDatesClean, self.exerciseDates) = self.cleanUpDates(dates: self.exerciseDates)

            self.currentExercise = self.exerciseNames[0]
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
                
                self.selectionTextField.text = "No Workouts Available"
                self.exercisePicker?.reloadAllComponents()
                self.getBarChartData()
                //case where user has no data
                self.selectionTextField.isEnabled = false
                self.barChartView.noDataText = "Complete an exercise for the data to be displayed"
            }
            
        }
    }
    
    //function to retrieve sets and reps data and display them
    @objc func getBarChartData(){
        
//        print("full id: ", self.fullIDSelected)
//        print("timestamps: ", self.fullTimestampSelected)
        
        if self.fullTimestampSelected == "All Dates" {
//            print("ALL Dates")
            self.barChartView.clear()
            
            //get a full history
            self.getTimeSpanSetsReps{ xSets, yVolume, wtPerSet, repsPerSet, setsList in
                //build the bar chart
                self.setLists = setsList
                self.setChart(dataPoints: xSets, values: yVolume, valuesWt: wtPerSet, valuesReps: repsPerSet)
                
            }
        }else{
        
        //get the sets and reps data to be displayed
        self.getMyHistoricalRepsSets { xSets, yVolume, wtPerSet, repsPerSet  in
            //build the bar chart
            self.setChart(dataPoints: xSets, values: yVolume, valuesWt: wtPerSet, valuesReps: repsPerSet)
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
        
        print("exerciseDates before: ", self.exerciseDates)
        (self.exerciseDatesClean, self.exerciseDates) = self.cleanUpDates(dates: self.exerciseDates)
        print("exerciseDates before: ", self.exerciseDates)
        
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
    func cleanUpDates(dates: [String])->([String],[String]){
        var refinedDates = [String]()
        var dateListDateType = [Date]()
        var nonRefinedDates = [String]()
        for x in dates {
        
//            "\(month)-\(day)-\(year):\(hour):\(minute):\(second)"
            formatter.dateFormat = "M-d-yyyy:H:m:s"
            formatter.timeZone = Calendar.current.timeZone //this timezone will print wrong (one less) but store right
            let date = formatter.date(from:x)!
            dateListDateType.append(date)
            
        }
        //sort dates
        dateListDateType = dateListDateType.sorted()

        for x in dateListDateType{
            formatter.dateFormat = "M-d-yyyy:H:m:s"
            let refurbishedDate = formatter.string(from: x)
            nonRefinedDates.append(refurbishedDate)
        }
        //selection set
//        self.exerciseDates = nonRefinedDates
        
        for x in dateListDateType{
            formatter.dateFormat = "MM-d-yyy"
            let refurbishedDate = formatter.string(from: x)
            refinedDates.append(refurbishedDate)
            
        }
//        print("refurbished date list:", refinedDates )
        return (refinedDates, nonRefinedDates)
    }
    
    //https://github.com/AshishKapoor/cex-graphs/blob/master/cex-graphs/CGMainViewController.swift
    //data points is x axis, values is the y axis
    func setChart(dataPoints: [String], values: [Double], valuesWt: [Double], valuesReps: [Double]) {
        var dataEntries1: [BarChartDataEntry] = []
        var dataEntries2: [BarChartDataEntry] = []
        var dataEntries3: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry1 = BarChartDataEntry(x: Double(i)+1, yValues: [values[i]])
            let dataEntry2 = BarChartDataEntry(x: Double(i)+1, yValues: [valuesWt[i]])
            let dataEntry3 = BarChartDataEntry(x: Double(i)+1, yValues: [valuesReps[i]])
            dataEntries1.append(dataEntry1)
            dataEntries2.append(dataEntry2)
            dataEntries3.append(dataEntry3)
        }
        
        
        let chartDataSet1 = BarChartDataSet(values: dataEntries1, label: "Total Volume of Weight Lifted")
        let chartData1 = BarChartData(dataSet: chartDataSet1)
        
        //color the graphs according to the days
        var colorsList = [NSUIColor]()
        
        print("setLists: ", self.setLists)
        var i = 0
        for x in self.setLists {
            //color code randomly by day
            var randomColor = UIColor.random()
            for _ in 1 ... x{
                colorsList.append(randomColor)
                
            }
            i = i + 1
        }
        chartDataSet1.colors = colorsList
        
        let chartDataSet2 = BarChartDataSet(values: dataEntries2, label: "Weight Lifted Per Set")
        let chartData2 = BarChartData(dataSet: chartDataSet2)
        chartDataSet2.colors = colorsList
        
        let chartDataSet3 = BarChartDataSet(values: dataEntries3, label: "Reps Per Set")
        let chartData3 = BarChartData(dataSet: chartDataSet3)
        chartDataSet3.colors = colorsList
        
        barChartView.data = chartData1
        weightBarChart.data = chartData2
        repsBarChart.data = chartData3
        
        barChartView.xAxis.labelCount = dataPoints.count
        weightBarChart.xAxis.labelCount = dataPoints.count
        repsBarChart.xAxis.labelCount = dataPoints.count
        barChartView.xAxis.labelTextColor = UIColor.black
        weightBarChart.xAxis.labelTextColor = UIColor.black
        repsBarChart.xAxis.labelTextColor = UIColor.black
        
        
    }

}

//random color
extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}
