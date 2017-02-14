//
//  ViewController.swift
//  SFGaugeView
//
//  Created by Krishnan Sriram Rama on 2/5/17.
//  Copyright © 2017 Krishnan Sriram Rama. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var topTachometer: SFGaugeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.topTachometer.bgColor = UIColor(red: CGFloat(249 / 255.0), green: CGFloat(203 / 255.0), blue: CGFloat(0 / 255.0), alpha: CGFloat(1))
        self.topTachometer.needleColor = UIColor(red: CGFloat(247 / 255.0), green: CGFloat(164 / 255.0), blue: CGFloat(2 / 255.0), alpha: CGFloat(1))
        self.topTachometer.isHideLevel = true
//        self.topTachometer.minImage = "minImage"
//        self.topTachometer.maxImage = "maxImage"
        self.topTachometer.isAutoAdjustImageColors = true
        self.topTachometer.currentLevel = 8
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

