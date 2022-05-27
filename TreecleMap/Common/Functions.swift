//
//  Functions.swift
//  wbs
//
//  Created by Home on 05/11/2019.
//  Copyright © 2019 Sidory. All rights reserved.
//

import UIKit

// MARK: - Devices
public func isIOS11() -> Bool{
    return CGFloat((UIDevice.current.systemVersion as NSString).floatValue) >= 11.0
}

public func isIOS8() -> Bool{
    return CGFloat((UIDevice.current.systemVersion as NSString).floatValue) >= 8.0
}

public func isIOS7() -> Bool{
    return CGFloat((UIDevice.current.systemVersion as NSString).floatValue) >= 7.0
}

public func isiPhone4() -> Bool{
    return UIScreen.main.bounds.size.height == 480.0
}

public func isiPhone5() -> Bool{
    return UIScreen.main.bounds.size.height == 568.0
}

public func isiPhone8() -> Bool{
    return UIScreen.main.bounds.size.height == 812.0
}

public func isiPhoneX() -> Bool{
    return UIScreen.main.bounds.size.height == 812.0
}

public func isiPhoneXr() -> Bool{
    return UIScreen.main.bounds.size.height == 896.0
}

public func isiPhoneXs() -> Bool{
    return UIScreen.main.bounds.size.height == 896.0
}

public func isiPhoneXsMax() -> Bool{
    return UIScreen.main.bounds.size.height == 896.0
}

public func isiPhoneXseries() -> Bool{
    if isiPhoneX() || isiPhoneXr() || isiPhoneXs() || isiPhoneXsMax() {
        return true
    }
    return false
}

public func isiPad() -> Bool {
    if UIDevice.current.userInterfaceIdiom == .pad {
        return true
    }
    return false
}


/// MARK:- Global Funcs
/// 단말 전체 Width
public func getDeviceWidth() -> CGFloat {
    return UIScreen.main.bounds.width
}

/// 단말 전체 Height
public func getDeviceHeight() -> CGFloat {
    return UIScreen.main.bounds.height
}

// MARK-: Debug Print
public func debug(_ message: String..., separator: String = "") {
    #if DEBUG
    if separator == "" {
        Swift.print(message)
    } else {
        Swift.print(message, separator: separator)
    }
    #endif
}

public func debugPrint(_ items: Any...) {
    #if DEBUG
    Swift.debugPrint(items)
    #endif
}
