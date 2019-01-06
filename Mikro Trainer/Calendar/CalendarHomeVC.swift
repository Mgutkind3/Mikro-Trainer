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

    @IBOutlet weak var removeBtnOut: UIButton!
    
    var selectedDates = [String]()//populate upon opening this document
    var selectedDate = String()
    var workoutsList = [String]()//list of workouts
    var workoutDict = [String: String]()//dictionary of workouts
    
    var userID = String()
    var ref: DatabaseReference?
    var myWorkoutsVC = MyWorkoutsVC()
    //picker
    private var workoutPicker: UIPickerView?
    @IBOutlet weak var workoutTypeField: UITextField!
    
    @IBOutlet weak var workoutSummaryLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Calendar"
        
        //weight picker view
        workoutPicker = UIPickerView()
        workoutPicker?.delegate = self
        workoutPicker?.dataSource = self
        workoutTypeField.inputView = workoutPicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        let sButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(saveButtonFunc))
        let cButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(cancelButtonFunc))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil);
        toolBar.setItems([sButton, flexibleSpace, cButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        workoutTypeField.inputAccessoryView = toolBar
    }
    
    //save right now
    @objc func saveButtonFunc(){
        print("saving")
        self.workoutTypeField.isHidden = true
        self.dismissKeyboard()
        
        //dont let the default text fill the value if the picker isnt touched
        if workoutTypeField.text == "Schedule Workout"{
            workoutTypeField.text = workoutsList[0]
        }
        //present alert to confirm scheduled workout
        let alert = UIAlertController(title: "Confirm", message: "Confirm your scheduled workout of \(self.workoutTypeField.text!) on \(self.selectedDate)?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: { action in
            
        self.ref?.child("Users").child(self.userID).child("ScheduledWorkouts").child(self.selectedDate).setValue(self.workoutTypeField.text!)
            //add newly cheduled date to workoutDict
            self.workoutDict[self.selectedDate] = self.workoutTypeField.text!
            self.calendarGridView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        //prompt the user with a notification if they'd like to save the app
    }
    
    @objc func cancelButtonFunc(){
        self.dismissKeyboard()
        self.workoutTypeField.isHidden = true
        self.workoutTypeField.text = "Schedule Workout"
    }
    
    //action to remove workout from databse and the calendar
    @IBAction func removeWorkoutBtn(_ sender: Any) {
        print("removing workout")
        let workoutToRemove = self.workoutDict[self.selectedDate]!
        let removeAlert = UIAlertController(title: "Remove Scheduled Workout", message: "Are you sure you want to remove \(workoutToRemove) on \(self.selectedDate)?", preferredStyle: UIAlertController.Style.alert)
        removeAlert.addAction(UIAlertAction(title: "Remove it!", style: UIAlertAction.Style.default, handler: { action in
            //remove date from database
            self.ref?.child("Users").child(self.userID).child("ScheduledWorkouts").child(self.selectedDate).setValue(nil)
            //remove workout from dictionary
            self.workoutDict.removeValue(forKey: self.selectedDate)
            self.workoutSummaryLbl.isHidden = true
            self.removeBtnOut.isHidden = true

            self.calendarGridView.reloadData()
        }))
        removeAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(removeAlert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        setUpCalendarView()
        
        self.workoutTypeField.isHidden = true
        self.workoutSummaryLbl.text = ""
        self.workoutSummaryLbl.isHidden = true
        self.removeBtnOut.isHidden = true
        
        //get user id
        self.ref = Database.database().reference()
        self.userID = String(Auth.auth().currentUser!.uid)
        
        self.myWorkoutsVC.getAllMyWorkouts(userID: self.userID, ref: self.ref!) { (list) in
            self.workoutsList = list
            self.seperateDatesNames(prevWorkoutsList: self.workoutsList)
            self.workoutPicker?.reloadAllComponents()
        }
        
        //get scheduled workouts
        self.getMyScheduledWorkouts {
            print("done getting scheduled workouts")
            
            self.calendarGridView.reloadData()
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
    
    //developer fix for bugs
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        _ = cell as! CalendarCell
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
        
        //highlight scheduled workouts
        formatter.dateFormat = "MM-dd-yyyy"
        formatter.timeZone = Calendar.current.timeZone //this timezone will print wrong (one less) but store right
        let curDate = formatter.string(from: date)//current date selected
        let now = Date()//todays date
        
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
        }else{
            //highlight scheduled days
            if let _ = self.workoutDict[curDate]{//how to check if a value is within a dictionary
                //if day is in the past highlight green
                if date < now {
                    cell.backgroundColor = UIColor.green
                }else{
                    cell.backgroundColor = UIColor.yellow
                }
            }else{
            //not today and not a scheduled workout
            cell.backgroundColor = UIColor.white
            }
        }
        
        cell.layer.cornerRadius = cell.frame.width / 2
        
        return cell
    }
    
    //code for when a user selects a date
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCell else {return}
        
        validCell.backgroundColor = UIColor.orange
        
        let now = Date()
        formatter.dateFormat = "MM-dd-yyyy"
        formatter.timeZone = Calendar.current.timeZone //this timezone will print wrong (one less) but store right
        self.selectedDate = formatter.string(from: date)//date of selected day
        print("selected date: ", selectedDate)
        
        //if statement checking if date is in the past
        //make sure date doesnt already exist in the list
        if date < now {
            print("Date is in the past")
            self.workoutTypeField.isHidden = true
            self.removeBtnOut.isHidden = true
            //todays date
            if Calendar.current.isDateInToday(date){
                self.tabBarController?.selectedIndex = 1
            }
            //previous date with completed workout
            if let val = self.workoutDict[selectedDate]{
                self.workoutSummaryLbl.text = "Completed Workout: \(val) on \(self.selectedDate)"
                self.workoutSummaryLbl.isHidden = false
            }else{
                //previous date without scheduled workout
                self.workoutSummaryLbl.isHidden = true
            }
        }else{
            //planned workout in the future
            if let val = self.workoutDict[selectedDate]{
                self.workoutSummaryLbl.text = "Cancel Workout: \(val) on \(self.selectedDate)?"
                self.workoutSummaryLbl.isHidden = false
                self.removeBtnOut.isHidden = false
                self.workoutTypeField.isHidden = true
            }else{
                //unplanned workout in the future
                self.workoutTypeField.text = "Schedule Workout"
                self.workoutTypeField.isHidden = false
                self.workoutSummaryLbl.isHidden = true
                self.removeBtnOut.isHidden = true
            }
        }
        
    }
    
    //deselect date
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCell else {return}
        
        //highlight scheduled workouts
        formatter.dateFormat = "MM-dd-yyyy"
        formatter.timeZone = Calendar.current.timeZone //this timezone will print wrong (one less) but store right
        let curDate = formatter.string(from: date)
        let now = Date()
        
        if Calendar.current.isDateInToday(date){
            validCell.backgroundColor = UIColor.cyan
        }else{
            
            //highlight scheduled days
            if let _ = self.workoutDict[curDate]{//how to check if a value is within a dictionary
                if date < now {
                    validCell.backgroundColor = UIColor.green
                }else{
                    validCell.backgroundColor = UIColor.yellow
                }
            }else{
                //not today and not a scheduled workout
                validCell.backgroundColor = UIColor.white
            }
        }
        
    }
    
    
}
