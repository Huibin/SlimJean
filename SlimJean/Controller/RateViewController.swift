//
//  RateViewController.swift
//  SlimJean
//
//  Created by huibin on 2016-09-04.
//  Copyright © 2016 huibin. All rights reserved.
//

import UIKit
import CoreData

class RateViewController: UIViewController {

    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var recordsTable: UITableView!
    
    var managedContext: NSManagedObjectContext!
    var records: [Record]? {
        didSet {
            calculateRate()
            updateUI()
        }
    }
    var latestMonthWeight: [Double] = []
    var rate: Double?
    var shapeLayer = CAShapeLayer()
    var refresh = false {
        didSet {
            fetchData()
        }
    }
    
// MARK: - function
    override func viewWillAppear(animated: Bool) {
        refresh = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        recordsTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "WeightRecord")
        recordsTable.delegate = self
        recordsTable.tableFooterView = UIView(frame: CGRectZero)
    }

    func fetchData() {
        if refresh == false {
            return
        }
        
        let request = NSFetchRequest(entityName: "Record")
        let sort = NSSortDescriptor(key: "created_at", ascending: true)
        request.sortDescriptors = [sort]
        
        records = try! managedContext.executeFetchRequest(request) as! [Record]
        refresh = false
    }
    
    func calculateRate() {
        if blank(records) || (records?.isEmpty)! { return }
        
        for (index, record) in records!.enumerate() {
            if index > 29 {
                return
            }
            latestMonthWeight.append(record.weight as! Double)
        }
     
        let lastWeight = records!.last!.weight as! Double
        let firstWeight = records!.first!.weight as! Double
        rate = records!.count < 2 ? 0 : (lastWeight - firstWeight)/firstWeight
        rate = rate!.roundToPlaces(4) * 100
    }
    
    func updateUI() {
        if blank(records) || (records?.isEmpty)! {
            rateLabel.text = "No Records Found"
            rateLabel.textColor = SJColor.grey
            chartView.backgroundColor = SJColor.grey
        } else {
            guard let latestRate = rate else { return }
            rateLabel.text = latestRate > 0 ? "Gaining Weight \(latestRate)%" : "Losing Weight \(-latestRate)%"
            rateLabel.textColor = latestRate > 0 ? SJColor.red : SJColor.blue
            
            drawChart()
        }
        
        recordsTable.reloadData()
    }
    
    func drawChart() {
        shapeLayer.removeFromSuperlayer()
        
        let xInterval = Double((chartView.frame.maxX - chartView.frame.minX)) / Double(latestMonthWeight.count)
        let yBase = Double(chartView.frame.maxY)
        let yInterval = Double((chartView.frame.maxY - chartView.frame.minY)) / latestMonthWeight.maxElement()!
        
        var points: [CGPoint] = []
        
        for (index, weight) in latestMonthWeight.enumerate() {
            let point = CGPoint(x: xInterval * Double(index), y: yBase - yInterval * weight)
//            let pointView = UIView(frame: CGRect(origin: point, size: CGSize(width: 10, height: 10)))
//            pointView.backgroundColor = SJColor.orange
//            pointView.layer.cornerRadius = 10
//            pointView.layer.masksToBounds = true
//            
//            chartView.addSubview(pointView)
            points.append(point)
        }
        
        let path = UIBezierPath()
        for (index, point) in points.enumerate() {
            if index == 0 {
                path.moveToPoint(CGPoint(x: point.x, y: chartView.frame.maxY))
                path.addLineToPoint(point)
            } else {
                path.addLineToPoint(point)
            }
        }
        path.addLineToPoint(CGPoint(x: points.last!.x, y: chartView.frame.maxY))
        
        
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = UIColor.clearColor().CGColor
        shapeLayer.fillColor = (!blank(rate) && rate! < 0) ? SJColor.lightBulue.CGColor : SJColor.lightOrange.CGColor
        shapeLayer.lineWidth = 1.0
        
        chartView.layer.addSublayer(shapeLayer)
    }
}


extension RateViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if blank(records) || (records?.isEmpty)! { return 0 }
        return records!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = recordsTable.dequeueReusableCellWithIdentifier("WeightRecord", forIndexPath: indexPath)
        if blank(records) || (records?.isEmpty)! {
            return cell
        }

        let selectView = UIView(frame: CGRect.zero)
        selectView.backgroundColor = SJColor.lightBulue
        cell.selectedBackgroundView = selectView
        
        let record = records![indexPath.row]
        cell.textLabel?.text = "\(record.created_on!): \(record.weight!) LB"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
 
