
//
//  Elixir.swift
//  Elixir_skad
//
//  Created by Kevin Bravo on 10/07/2020.
//  Copyright © 2020 Kevin Bravo. All rights reserved.
//

import Foundation
import UIKit

class Elixir {
    
    private var conversionTableURL: String = ""
    //Contains all the conversions you want to track, as well as their "hooks"
    private var conversionTable: [Conversion] = []
    
    static var binaryMatchingTable: [Int: String] = [
        1:"001",
        2:"010",
        3:"011",
        4:"100",
        5:"101",
        6:"110",
        7:"111"
    ]
    
    private var progressBinary = "000"
    private var revenueBinary = "000"
    
    
    private static var _instance: Elixir = {
        return Elixir()
    }()

    
    //Init
    public func initializeWith(url: String) {
        Elixir.instance().conversionTableURL = url
        Elixir.instance().retrieveConversionData()
        Elixir.instance().retrieveLatestBinaries()
    }
    
    class func instance() -> Elixir {
        return _instance
    }
    
    private func retrieveConversionData() {
        //verify if conversion data available, otherwise request it
        if UserDefaults.standard.value(forKey: "conversionTableData") == nil {
            Elixir.instance().requestConversionFile()
        }
    }
    
    //retrieve latest binary values
    private func retrieveLatestBinaries() {
        if let revenueBinary = UserDefaults.standard.value(forKey: "revenueBinary") as? String,
            let progressBinary = UserDefaults.standard.value(forKey: "progressBinary") as? String {
            self.revenueBinary = revenueBinary
            self.progressBinary = progressBinary
        }
    }
    
    //TODO: handles dynamic URL in SDK setup
    private func requestConversionFile() {
        
        let url = URL(string: conversionTableURL)
        guard let requestUrl = url else {
            print("error with URL")
            return

        }

        var request = URLRequest(url: requestUrl)

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            }
            
            if let data = data {
                Elixir.instance().store(data)
            }
        }
        task.resume()
    }
    
    private func store(_ data: Data) {
        UserDefaults.standard.set(data, forKey: "conversionTableData") //Bool
    }
    
    private func decode(_ data: Data) {

        var _conversionsTable: [Conversion] = []
        
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let conversions = json as? [Any] {
            for _conv in conversions {
                
                if let conversion = _conv as? [String : Any] {
                    if let id = conversion["ConversionName"] as? String,
                        let type = conversion["Type"] as? String,
                        let priority = conversion["PriorityFactor"] as? Int,
                        let _hook = conversion["Hook"] as? [Any],
                        let hook = _hook[0] as? [String: Any] {
                        if let eventName = hook["EventName"] as? String {
                            
                            //optionals
                            let condition = hook["WHERE"] as? String
                            let attribute = hook["eventAttribute"] as? String
                            let value = hook["toValue"] as? String
                            
                            //TODO: manage multiple events
                            let hook = Hook(eventName: eventName, condition: condition, attribute: attribute, value: value)
                            
                            let conversion = Conversion(name: id, hooks: [hook], type: type, priority: priority)
                            
                            _conversionsTable.append(conversion)
                        }
                    }
                }
            }
            Elixir.instance().conversionTable = _conversionsTable
        }
    }
    
    func logEvent(_ event: String, withProperties properties: [String: AnyHashable]?) {
        
        Elixir.identifyConversionValue(forEvent: event, andProperties: properties)
        
        if let value = Int(revenueBinary+progressBinary, radix: 2) {
            Elixir.instance().store(revenueBinary, progressBinary)
            Skadnetwork.updateConversionValue(value)
        }
    }
    
    func store(_ revenueBinary: String, _ progressBinary: String) {
        UserDefaults.standard.set(revenueBinary, forKey: "revenueBinary")
        UserDefaults.standard.set(progressBinary, forKey: "progressBinary")
    }
    
  
    
    class func identifyConversionValue(forEvent event: String, andProperties properties: [String: AnyHashable]? ) {
        
        guard Elixir.instance().conversionTable.count != 0 else {
            if let data = UserDefaults.standard.value(forKey: "conversionTableData") as? Data {
                Elixir.instance().decode(data)
            }
            return
        }
        var confirmedConversions: [Conversion] = []

        for conversion in Elixir.instance().conversionTable {
            for hook in conversion.hooks {
                if hook.eventName == event {
                    if hook.attribute == nil || Elixir.instance().confirmMatch(forHook: hook, withProperties: properties) {
                        confirmedConversions.append(conversion)
                    }
                }
            }
        }
        
        if confirmedConversions.count > 0 {
            
            if let highestConversion = confirmedConversions.max(by: { $0.priority < $1.priority}) {
                
                //TODO: manage multiple events
                switch highestConversion.type {
                case "Progress":
                    Elixir.instance().progressBinary = binaryMatchingTable[highestConversion.priority] ?? "000"
                case "Revenue":
                    Elixir.instance().revenueBinary = binaryMatchingTable[highestConversion.priority] ?? "000"
                default:
                    break
                }
            }
        }
    }
    
    private func confirmMatch(forHook hook: Hook, withProperties properties: [String: AnyHashable]?) -> Bool {
        
        
        if let hookvalue = Int(hook.value ?? ""),
        hook.attribute != nil && properties != nil,
        let eventValue = properties![hook.attribute!] as? String,
        let _eventValue = Int(eventValue.description) {
            
        switch hook.condition {
        case "isHigher":
            
            if _eventValue > hookvalue {
                return true
            }
            
        case "isLower":
            if _eventValue < hookvalue {
                return true
            }
            
        case "isEqual":
            if _eventValue == hookvalue {
                return true
            }
        case "isNotEqual":
            if _eventValue != hookvalue {
                return true
            }
        default:
            return true
            }
        }
        return false
    }
}


class Conversion {
    var name: String
    var hooks: [Hook]
    var type: String
    var priority: Int
    
    init(name: String, hooks: [Hook], type: String, priority: Int) {
        self.name = name
        self.hooks = hooks
        self.type = type
        self.priority = priority
    }
}

struct Hook {
    var eventName: String
    var condition: String?
    var attribute: String?
    var value: String?
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
