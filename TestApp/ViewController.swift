//
//  ViewController.swift
//  TestApp
//
//  Created by Joker on 5/11/21.
//  Copyright © 2021 Elena Prokofeva. All rights reserved.
//

import UIKit
import AdSupport

class ViewController: UIViewController {

    @IBOutlet weak var indentifier: UILabel!
    
    @IBOutlet weak var indentifierAdvertising: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HelloFromC()
        
        func identifierForAdvertising() -> String? {
            // Check whether advertising tracking is enabled
            guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
                return nil
            }
            
            // Get and return IDFA
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
        
        let idAdvertising:String? = identifierForAdvertising()
        
        if let idAdver = idAdvertising {
            indentifierAdvertising.text = idAdver
        } else {
            indentifierAdvertising.text = "It doesn't work"
        }
        
        //let testUUID = NSUUID().uuidString //This method was use before with Objective-C
        //let testUUID = UIDevice.currentDevice().identifierForVendor.UUIDString // Maybe this method had been working before SWIFT 4.1 version
        let testUUID:String? = UIDevice.current.identifierForVendor?.uuidString
        
        if let UUID = testUUID  {
            indentifier.text = UUID
        } else {
            indentifier.text = "It doesn't work"
        }
        
        
    }

    

}

