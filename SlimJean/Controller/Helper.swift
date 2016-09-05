// helper functions

import UIKit
import Foundation

func blank<T>(variable: T?) -> Bool {
    return variable == nil
}


func dateString(date: NSDate) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.stringFromDate(date)
}


extension Double {
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}