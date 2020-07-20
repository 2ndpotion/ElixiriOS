//
//  ViewController.swift
//  ElixiriOS
//
//  Created by kevin@2ndpotion.com on 07/20/2020.
//  Copyright (c) 2020 kevin@2ndpotion.com. All rights reserved.
//

import UIKit
import ElixiriOS

class ViewController: UIViewController {
    
    
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventPropertyTextField: UITextField!
    @IBOutlet weak var propertyValueTextField: UITextField!
    @IBOutlet weak var conversionTableTextView: UITextView!

    
    @IBAction func sendEventData(_ sender:UIButton) {
        
        let event = eventNameTextField.text ?? ""
        let properties = [eventPropertyTextField.text ?? "": propertyValueTextField.text ?? ""]
        
        //Log an event
        Elixir.instance().logEvent(event, withProperties: properties)
    }
    
    @IBAction func requestConversionValue(_ sender:UIButton) {
        showAlert(title: "Latest conversionPayload", message: "Conversion value sent to SKADNetwork :\(Elixir.instance().retrieveConversionValue())") {}
    }
    
    @IBAction func getConversionTable(_ sender:UIButton) {
        if let data = Elixir.instance().getConversionTable() {
            let str = String(decoding: data, as: UTF8.self)
            self.conversionTableTextView.text =  str
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension UIViewController {

  func showAlert(title: String, message: String, callback: @escaping () -> ()) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
     alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
       alertAction in
       callback()
     }))

     self.present(alert, animated: true, completion: nil)
   }

   //add additional functions here if necessary
   //like a function showing alert with cancel
}
