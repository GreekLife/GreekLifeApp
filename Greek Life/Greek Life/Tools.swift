//
//  InternetConnectivity.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-10-22.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import Foundation
import UIKit

//For Swift 3, Swift 4 :Working in cellular and Wi - Fi

import SystemConfiguration

public class GenericTools {
    //--Directly applies edit to passed view--//
    class func FrameToFitTextView(View: UITextView){
        let fixedWidth = View.frame.size.width
        View.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = View.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = View.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        View.frame = newFrame
    }
}

public class mergeSorting {
    
class func mergeSort<T: Comparable>(_ array: [T]) -> [T] {
        guard array.count > 1 else { return array }
        
        let middleIndex = array.count / 2
        
        let leftArray = mergeSort(Array(array[0..<middleIndex]))
        let rightArray = mergeSort(Array(array[middleIndex..<array.count]))
        
        return merge(leftArray, rightArray)
    }
    
class func merge<T: Comparable>(_ left: [T], _ right: [T]) -> [T] {
        var leftIndex = 0
        var rightIndex = 0
        
        var orderedArray: [T] = []
        
        while leftIndex < left.count && rightIndex < right.count {
            let leftElement = left[leftIndex]
            let rightElement = right[rightIndex]
            
            if leftElement < rightElement {
                orderedArray.append(leftElement)
                leftIndex += 1
            } else if leftElement > rightElement {
                orderedArray.append(rightElement)
                rightIndex += 1
            } else {
                orderedArray.append(leftElement)
                leftIndex += 1
                orderedArray.append(rightElement)
                rightIndex += 1
            }
        }
        
        while leftIndex < left.count {
            orderedArray.append(left[leftIndex])
            leftIndex += 1
        }
        
        while rightIndex < right.count {
            orderedArray.append(right[rightIndex])
            rightIndex += 1
        }
        
        return orderedArray
    }
}

public class ActivityWheel {
    
    class func CreateActivity(activityIndicator: UIActivityIndicatorView, view: UIView) {
        activityIndicator.center = view.center;
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge;
        activityIndicator.color = UIColor.blue;
        view.addSubview(activityIndicator);
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents();
    }
}

public class CreateDate {
    class func getCurrentDate(epoch:Double)->String{
        let date = NSDate(timeIntervalSince1970: epoch)
        let formattedDate = formatDate(date: date)
        return formattedDate
    }
    class func formatDate(date:NSDate)->String{
        let formater = DateFormatter()
        formater.dateFormat = "MMM dd YYYY, hh:mm"
        let dateString = formater.string(from: date as Date)
        return dateString
    }
}

public class Banner {
    class func ErrorBanner(errorTitle:String)->UILabel{
        let internetError = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 70))
        internetError.textColor = .red
        internetError.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        internetError.textAlignment = .center
        internetError.text = errorTitle
        print("Internet Connection not Available!")
        return internetError
    }
}

public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
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
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
}
}
