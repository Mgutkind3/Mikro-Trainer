//
//  CalendarHomeVC.swift
//  Mikro Trainer
//
//  Created by Michael Gutkind on 12/27/18.
//  Copyright © 2018 Michael Gutkind. All rights reserved.
//

import UIKit
import JTAppleCalendar
import FirebaseAuth
import FirebaseDatabase

class CalendarHomeVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return workoutsList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return workoutsList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let workout = workoutsList[pickerView.selectedRow(inComponent: 0)]
        self.workoutTypeField.text = "\(workout)"
        
    }
    

    //https://github.com/patchthecode/JTAppleCalendar/issues/553
    
    
    @IBOutlet weak var calendarGridView: JTAppleCalendarView!
    
    let formatter = DateFormatter()
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    var selectedDates = [String]()//populate upon opening this document
    let selectedDate = String()
    var workoutsList = [String]()//list of workouts
    
    var userID = String()
    var ref: DatabaseReference?
    var myWorkoutsVC = MyWorkoutsVC()
    //picker
    private var workoutPicker: UIPickerView?
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var addWrkSchBtn: UIBarButtonItem!
    @IBOutlet weak var workoutTypeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //weight picker view
        workoutPicker = UIPickerView()
        workoutPicker?.delegate = self
        workoutPicker?.dataSource = self
        workoutTypeField.inputView = workoutPicker
        self.workoutTypeField.isHidden = true
        self.hideKeyboardWhenTappedAround()
        self.addWrkSchBtn.isEnabled = false
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        let sButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(saveButtonFunc))
        toolBar.setItems([sButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        workoutTypeField.inputAccessoryView = toolBar
        
        setUpCalendarView()
        // Do any additional setup after loading the view.
    }
    
    @objc func saveButtonFunc(){
        print("saving")
        self.workoutTypeField.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //get user id
        self.ref = Database.database().reference()
        self.userID = String(Auth.auth().currentUser!.uid)
        
        self.myWorkoutsVC.getAllMyWorkouts(userID: self.userID, ref: self.ref!) { (list) in
            self.workoutsList = list
            self.seperateDatesNames(prevWorkoutsList: self.workoutsList)
            self.workoutPicker?.reloadAllComponents()
        }
    }
    
    //function to split days from names
    func seperateDatesNames(prevWorkoutsList: [String]){
        var splitItemList = [String]()
        for x in self.workoutsList{
            if x.contains(":"){
                let splitItems = x.split(separator: ":", maxSplits: 1)
                splitItemList.append(String(splitItems[1]))
            }else{
                print("doesnt have : ")
            }
        }
        //re use list to contain just workout names
        self.workoutsList = splitItemList
        print("Workout list check: ", self.workoutsList)
    }
    
    //function to set up everything for the calendar
    func setUpCalendarView(){
        
        calendarGridView.visibleDates { visibleDates in
            let date = visibleDates.monthDates.first!.date
            
            self.formatter.dateFormat = "yyyy"
            self.yearLabel.text = self.formatter.string(from: date)
            
            self.formatter.dateFormat = "MMMM"
            self.monthLabel.text = self.formatter.string(from: date)
        }
        
        self.calendarGridView.scrollToDate(Date(),animateScroll: false)

    }
    
    //function to add a planned workout
    @IBAction func planNewWorkoutDate(_ sender: Any) {
        
        if selectedDates.contains(selectedDate){
            //ask user whether they want to delete or not
        }else{
            //ask user if they want to plan a new workout
            self.workoutTypeField.isHidden = false
        }
    }
    
    @IBAction func saveBtnAction(_ sender: Any) {
        self.workoutTypeField.isHidden = true
    }
    

}

extension CalendarHomeVC: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    //refresh after the user scrolls the calendar
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date

        formatter.dateFormat = "yyyy"
        self.yearLabel.text = formatter.string(from: date)

        formatter.dateFormat = "MMMM"
        self.monthLabel.text = formatter.string(from: date)
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let myCalendarCell = cell as! CalendarCell
        print(myCalendarCell)
    }
    
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
//                let now = Date()
        //only let calendar plan 6 months ahead or 6 months behind
        let threeMonthsAhead = Calendar.current.date(byAdding: .month, value: 6, to: Date())!
        let threeMonthsBehind = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
        
        let startDate = threeMonthsBehind
        let endDate = threeMonthsAhead
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        
        return parameters
    }
    
    //format each cell
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        //fix bug in will display function
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        
        cell.dateLabel.text = cellState.text
        
        
        //make days of this month black and days of other month's dark grey
        if cellState.dateBelongsTo == .thisMonth{
            cell.dateLabel.textColor = UIColor.black
        }else{
            cell.dateLabel.textColor = UIColor.lightGray
        }
        
        //highlight today
        if Calendar.current.isDateInToday(date){
            //today
            cell.backgroundColor = UIColor.cyan
            cell.layer.cornerRadius = cell.frame.width / 2
        }else{
            //not today
            cell.backgroundColor = UIColor.white
            cell.layer.cornerRadius = cell.frame.width / 2
        }
        
        return cell
    }
    
    //code for when a user selects a date
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCell else {return}
        
        validCell.backgroundColor = UIColor.orange
        self.addWrkSchBtn.isEnabled = true
        
        formatter.dateFormat = "MM-dd-yyyy"
        formatter.timeZone = Calendar.current.timeZone //this timezone will print wrong (one less) but store right
        let selectedDate = formatter.string(from: date)//date of selected day
        print("selected date: ", selectedDate)
        
    }
    
    //deselect date
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCell else {return}
        if Calendar.current.isDateInToday(date){
            validCell.backgroundColor = UIColor.cyan
        }else{
            validCell.backgroundColor = UIColor.white
        }
        
    }
    
    
}
