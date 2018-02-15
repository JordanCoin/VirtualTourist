//
//  Utils.swift
//  Virtual Tourist
//
//  Created by Jordan Jackson on 2/7/18.
//  Copyright © 2018 Jordan Jackson. All rights reserved.
//

import UIKit
import MapKit
import SystemConfiguration

class Utils: UIViewController {
    // MARK: - Error Handling
    static func errorAlert(title: String, message: String, view: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            view.present(alert, animated: true, completion: nil)
        }
    }
    
    func connectedToNetwork() -> Bool {
        if Reachability.connectedToNetwork() {
            return true
        } else {
            return false
        }
    }
}
// MARK: - Connecting to Network
// Source: StackOverflow
public class Reachability {
    
    class func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired
        
        return isReachable && !needsConnection
    }
}
