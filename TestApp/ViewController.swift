//
//  ViewController.swift
//  TestApp
//
//  Created by Joker on 5/11/21.
//  Copyright © 2021 Elena Prokofeva. All rights reserved.
//

import UIKit
import AdSupport
import Network

class ViewController: UIViewController {

    @IBOutlet weak var indentifier: UILabel!
    
    @IBOutlet weak var indentifierAdvertising: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HelloFromC()
        
        guard let wifiIp = getAddress(for: .wifi) else { return }
        guard let cellularIp = getAddress(for: .cellular) else { return }
//        guard let ipv4 = getAddress(for: .ipv4) else { return }
//        guard let ipv6 = getAddress(for: .ipv6) else { return }
        
        
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



// Return IP address of WiFi interface (en0) as a String, or `nil`
func getWiFiAddress() -> String? {
    var address : String?
    
    // Get list of all interfaces on the local machine:
    var ifaddr : UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return nil }
    guard let firstAddr = ifaddr else { return nil }
    
    // For each interface ...
    for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let interface = ifptr.pointee
        
        // Check for IPv4 or IPv6 interface:
        let addrFamily = interface.ifa_addr.pointee.sa_family
        if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
            
            // Check interface name:
            let name = String(cString: interface.ifa_name)
            if  name == "en0" {
                
                // Convert interface address to a human readable string:
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                            &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST)
                address = String(cString: hostname)
            }
        }
    }
    freeifaddrs(ifaddr)
    
    return address
}



// If you need came looking for more than the WIFI IP you could modify this code a little

func getAddress(for network: Network) -> String? {
    var address: String?
    
    // Get list of all interfaces on the local machine:
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return nil }
    guard let firstAddr = ifaddr else { return nil }
    
    // For each interface ...
    for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let interface = ifptr.pointee
        
        // Check for IPv4 or IPv6 interface:
        let addrFamily = interface.ifa_addr.pointee.sa_family
        if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
            
            // Check interface name:
            let name = String(cString: interface.ifa_name)
            if name == network.rawValue {
                
                // Convert interface address to a human readable string:
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                            &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST)
                address = String(cString: hostname)
            }
        }
    }
    freeifaddrs(ifaddr)
    
    return address
}


enum Network: String {
    case wifi = "en0"
    case cellular = "pdp_ip0"
//    case ipv4 = "ipv4"
//    case ipv6 = "ipv6"
}
