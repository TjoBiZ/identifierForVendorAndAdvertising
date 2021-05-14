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
import SystemConfiguration.CaptiveNetwork


class ViewController: UIViewController {

    @IBOutlet weak var indentifier: UILabel!
    @IBOutlet weak var indentifierAdvertising: UILabel!
    @IBOutlet weak var placeNetworkInformation: UILabel!
    @IBOutlet weak var routerIP: UILabel!
    @IBOutlet weak var BSSID: UILabel!
    @IBOutlet weak var SSID: UILabel!
    @IBOutlet weak var iOSVersion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HelloFromC()
        
        var networkInformation:String = ""
        
        for addr in getInterfaces() {
            //networkInformation += addr
            print(addr)
            networkInformation += "(name: " + addr.name + ", addr: " + addr.addr + ", mac: " + addr.mac + ") \n"
        }
        // (name: "en0", addr: "fe80::869:e8ce:db9a:737a%en0", mac: "02:00:00:00:00:00")
        // (name: "en0", addr: "192.168.100.7", mac: "02:00:00:00:00:00")
        // (name: "en2", addr: "fe80::89d:b5c2:fa1d:2e85%en2", mac: "02:00:00:00:00:00")
        // (name: "en2", addr: "169.254.233.103", mac: "02:00:00:00:00:00")
        // (name: "awdl0", addr: "fe80::20fd:f1ff:fe20:5843%awdl0", mac: "02:00:00:00:00:00")
        // (name: "utun0", addr: "fe80::8bfe:b836:f7ad:24b3%utun0", mac: "")
        // ......
        guard let wifiIp = getAddress(for: .wifi) else { return }
        guard let cellularIp = getAddress(for: .cellular) else { return }
        //        guard let ipv4 = getAddress(for: .ipv4) else { return }
        //        guard let ipv6 = getAddress(for: .ipv6) else { return }
        
        if let networkInfo:String = networkInformation {
            placeNetworkInformation.text = networkInfo
        } else {
            placeNetworkInformation.text = "It doesn't work"
        }
        
        
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
        
        
        let wifiNET:(String?, String?) = getWiFiSsid()

        if let wifiSsid = wifiNET.0 {
            SSID.text = "Wi-Fi Network: " + wifiSsid
        } else {
            SSID.text = "SSID doesn't work"
        }
        
        if let wifiSsid = wifiNET.1 {
            BSSID.text = "Mac address: " + wifiSsid
        } else {
            BSSID.text = "BSSID doesn't work"
        }


        let systemVersion:String? = UIDevice.current.systemVersion
        if let version = systemVersion {
            iOSVersion.text = "iOS version: " + version
        } else {
            iOSVersion.text = "Doesn't get version"
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




// Get all network Interfaces
func getInterfaces() -> [(name : String, addr: String, mac : String)] {
    
    var addresses = [(name : String, addr: String, mac : String)]()
    var nameToMac = [ String: String ]()
    
    // Get list of all interfaces on the local machine:
    var ifaddr : UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return [] }
    guard let firstAddr = ifaddr else { return [] }
    
    // For each interface ...
    for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let flags = Int32(ptr.pointee.ifa_flags)
        if let addr = ptr.pointee.ifa_addr {
            let name = String(cString: ptr.pointee.ifa_name)
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                switch Int32(addr.pointee.sa_family) {
                case AF_LINK:
                    // Get MAC address from sockaddr_dl structure and store in nameToMac dictionary:
                    addr.withMemoryRebound(to: sockaddr_dl.self, capacity: 1) { dl in
                        dl.withMemoryRebound(to: Int8.self, capacity: 8 + Int(dl.pointee.sdl_nlen + dl.pointee.sdl_alen)) {
                            let lladdr = UnsafeBufferPointer(start: $0 + 8 + Int(dl.pointee.sdl_nlen),
                                                             count: Int(dl.pointee.sdl_alen))
                            if lladdr.count == 6 {
                                nameToMac[name] = lladdr.map { String(format:"%02hhx", $0)}.joined(separator: ":")
                            }
                        }
                    }
                case AF_INET, AF_INET6:
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(addr, socklen_t(addr.pointee.sa_len),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        addresses.append( (name: name, addr: address, mac : "") )
                    }
                default:
                    break
                }
            }
        }
    }
    
    freeifaddrs(ifaddr)
    
    // Now add the mac address to the tuples:
    for (i, addr) in addresses.enumerated() {
        if let mac = nameToMac[addr.name] {
            addresses[i] = (name: addr.name, addr: addr.addr, mac : mac)
        }
    }
    
    return addresses
}


//Get SSID and BSSID

func getWiFiSsid() -> (String?, String?) {
    var ssid: String?
    var bssid: String?
    if let interfaces = CNCopySupportedInterfaces() as NSArray? {
        for interface in interfaces {
            if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                print("ssid:", ssid ?? "Can't get ssid")
                bssid = interfaceInfo[kCNNetworkInfoKeyBSSID as String] as? String
                print("bssid:", bssid ?? "Can't get bssid")
                break
            }
        }
    }
    return (ssid, bssid)
}


