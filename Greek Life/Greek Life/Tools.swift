//
//  InternetConnectivity.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-10-22.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

public class GenericTools {
    //--Directly applies edit to passed view--//
    class func FrameToFitTextView(View: UITextView){
        let fixedWidth = View.frame.size.width
        let newSize = View.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newFrame = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        View.frame.size = newFrame
    }
    
    class func ResizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    class func Logger(data: String) {
        debugPrint(data)
//        let path = Bundle.main.path(forResource: "Log", ofType: "txt")
//        let fileURL = URL(fileURLWithPath: path!)
//        do {
//            try text.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
//        } catch {
//            print("error")
//        }
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
    class func getTimeSince(epoch:Double)->String{
        let currentTime = NSDate().timeIntervalSince1970
        let secondsSince = currentTime - epoch
        let minutesSince = Int(secondsSince/60)
        let hoursSince = Int(secondsSince/3600)
        if minutesSince < 60 {
            return String(minutesSince) + "m"
        }
        else if hoursSince > 24 {
            let daysSince = Int(hoursSince / 24)
            return String(daysSince) + "d"
        }
        return String(hoursSince) + "h"
    }
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

//Jon's Version of CreateDate
public class theFormatter
{
    class func timeStringFromDate(_ date:Date)->String
    {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from:date)
    }
    
    class func dateStringFromDate(_ date:Date)->String
    {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from:date)
    }
    
    class func jonahStringFromDate(_ date:Date)->String
    {
        let formater = DateFormatter()
        formater.dateFormat = "MMM dd YYYY, hh:mm"
        return formater.string(from: date)
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

//For Swift 3, Swift 4 :Working in cellular and Wi - Fi
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


//Custom month/year picker jon found

class MonthYearPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var months: [String]!
    var years: [Int]!
    
    var month: Int = 0 {
        didSet {
            selectRow(month-1, inComponent: 0, animated: false)
        }
    }
    
    var year: Int = 0 {
        didSet {
            selectRow(years.index(of: year)!, inComponent: 1, animated: true)
        }
    }
    
    var onDateSelected: ((_ month: Int, _ year: Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonSetup()
    }
    
    func commonSetup() {
        // population years
        var years: [Int] = []
        
        if years.count == 0 {
            let currentYear = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.year, from: NSDate() as Date)
            for year in 1913...(currentYear+20) {
                years.append(year)
            }
        }
        self.years = years
        
        // population months with localized names
        var months: [String] = []
        var month = 0
        for _ in 1...12 {
            months.append(DateFormatter().monthSymbols[month].capitalized)
            month += 1
        }
        self.months = months
        
        self.delegate = self
        self.dataSource = self
        
        //let currentMonth = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.month, from: NSDate() as Date)
        //self.selectRow(currentMonth - 1, inComponent: 0, animated: false)
    }
    
    // Mark: UIPicker Delegate / Data Source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return months[row]
        case 1:
            return "\(years[row])"
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return months.count
        case 1:
            return years.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let month = self.selectedRow(inComponent: 0)+1
        let year = years[self.selectedRow(inComponent: 1)]
        if let block = onDateSelected {
            block(month, year)
        }
        
        self.month = month
        self.year = year
    }
    
}
