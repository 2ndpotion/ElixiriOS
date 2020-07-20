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

    override func viewDidLoad() {
        super.viewDidLoad()
        Elixir.instance().logEvent("eventName", withProperties: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

