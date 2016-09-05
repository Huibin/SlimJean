// Alert herlper


import UIKit
import Foundation

struct SJAlert {
    static func chooseAction(editAction: (inputValue: Double)->Void, deleteAction: ()->Void) -> UIAlertController {
        let alert = UIAlertController(title: "Edit Record", message: "Input new record or delete the current one.", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({
            (textField: UITextField!) in
            textField.keyboardType = .DecimalPad
        })
        
        let editAction = UIAlertAction(title: "Update", style: .Default, handler: { action in
            let tf = alert.textFields![0] as UITextField
            guard let weightNumber = Double(tf.text!) else { return }
            editAction(inputValue: weightNumber)
        })
        alert.addAction(editAction)
        
        let deletAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { action in deleteAction() })
        alert.addAction(deletAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        
        return alert
    }
    
    static func inputAction(addAction: (inputValue: Double)->Void) -> UIAlertController {
        let alert = UIAlertController(title: "Add Record", message: "Input your weight (lb).", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({
            (textField: UITextField!) in
            textField.keyboardType = .DecimalPad
        })
        
        let addAction = UIAlertAction(title: "Add", style: .Default, handler: { action in
            let tf = alert.textFields![0] as UITextField
            guard let weightNumber = Double(tf.text!) else { return }
            addAction(inputValue: weightNumber)
        })
        alert.addAction(addAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        
        return alert
    }
    
}