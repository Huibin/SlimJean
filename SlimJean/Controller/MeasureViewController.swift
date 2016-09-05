//
//  MeasureViewController.swift
//  SlimJean
//
//  Created by huibin on 2016-09-03.
//  Copyright © 2016 huibin. All rights reserved.
//

import UIKit
import CVCalendar
import CoreData

class MeasureViewController: UIViewController {
    var monthLabel: UILabel!
    var menuView: CVCalendarMenuView!
    var calendarView: CVCalendarView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var selectDate: NSDate?
    
    var managedContext: NSManagedObjectContext!
    var record: Record? {
        didSet {
            updateRecordUI()
        }
    }
    
    
 //MARK: - Function
    override func viewDidLoad() {
        super.viewDidLoad()

        selectDate = NSDate()
        initUI()
        fetchData(selectDate!)
    }

    func initUI() {
        monthLabel = UILabel(frame: CGRect(x: (view.frame.size.width-350)/2, y: 25, width: 350, height: 20))
        monthLabel!.font = UIFont.systemFontOfSize(12)
        monthLabel!.textColor = SJColor.blue
        monthLabel!.textAlignment = .Center
        monthLabel!.text = CVDate(date: NSDate()).globalDescription
        view.addSubview(monthLabel)
        
        menuView = CVCalendarMenuView(frame: CGRectMake((view.frame.size.width-350)/2, 50, 350, 20))
        menuView.menuViewDelegate = self
        view.addSubview(menuView)
        
        
        calendarView = CVCalendarView(frame: CGRectMake((view.frame.size.width-350)/2, 70, 350, 250))
        calendarView.calendarDelegate = self
        view.addSubview(calendarView)
        
        disableFuture()
        
        //TODO: disable furture date
//        calendarView.calendarAppearanceDelegate = self
//        calendarView.animatorDelegate = self
        
        dateLabel.text = dateString(selectDate!)
        actionButton.layer.cornerRadius = 10
        actionButton.layer.masksToBounds = true
    }
    
    func fetchData(selectDate: NSDate) {
        let request = NSFetchRequest(entityName: "Record")
        let predicate = NSPredicate(format: "created_on == %@", dateString(selectDate))
        request.predicate = predicate
    
        let result = try! managedContext.executeFetchRequest(request) as! [Record]
        record = result.isEmpty ? nil : result.first
    }
    
    func updateRecordUI() {
        recordLabel.text = blank(record) ? "No Record" : "\(record!.weight!) LB"
        actionButton.setTitle(blank(record) ? "Add" : "Edit", forState: .Normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }

    @IBAction func recordWeight(sender: UIButton) {
        let alert = blank(record) ? SJAlert.inputAction(addRecod) : SJAlert.chooseAction(editRecord, deleteAction: deleteRecord)
        presentViewController(alert, animated: true, completion: nil)
    }
}


extension MeasureViewController: CVCalendarMenuViewDelegate, CVCalendarViewDelegate {
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        return false
    }
    
    func presentedDateUpdated(date: CVDate) {
        monthLabel.text = date.globalDescription
    }
    
    func didSelectDayView(dayView: DayView, animationDidFinish: Bool) {
        selectDate = dayView.date.convertedDate()!
        dateLabel.text = dateString(selectDate!)
        fetchData(selectDate!)
    }
    
    func didShowPreviousMonthView(date: NSDate) {
        disableFuture()
    }
    
    func didShowNextMonthView(date: NSDate) {
        disableFuture()
    }
    
    func disableFuture() {
        let calendar = NSCalendar.currentCalendar()
        
        for weekV in calendarView.contentController.presentedMonthView.weekViews {
            for dayView in weekV.dayViews {
                if calendar.compareDate(dayView.date.convertedDate()!, toDate: NSDate(), toUnitGranularity: .Day) == .OrderedDescending  {
                    dayView.userInteractionEnabled = false
                    dayView.dayLabel.textColor = calendarView.appearance.dayLabelWeekdayOutTextColor
                }
            }
        }
    }
}

extension MeasureViewController {
    func addRecod(weight: Double) {
        let record = NSEntityDescription.insertNewObjectForEntityForName("Record", inManagedObjectContext: managedContext) as! Record
        record.weight = NSNumber.init(double: weight)
        record.created_on = dateString(selectDate!)
        record.created_at = selectDate!
        
        do {
            try managedContext.save()
            fetchData(selectDate!)
        } catch {
            managedContext.rollback()
        }
    }
    
    func editRecord(weight: Double) {
        guard let currentRecord = record else { return }
        currentRecord.weight = NSNumber.init(double: weight)
        do {
            try managedContext.save()
            fetchData(selectDate!)
        } catch {
            managedContext.rollback()
        }
    }
    
    func deleteRecord() {
        guard let currentRecord = record else { return }
        managedContext.deleteObject(currentRecord)
        do {
            try managedContext.save()
            fetchData(selectDate!)
        } catch {
            managedContext.rollback()
        }
    }
}