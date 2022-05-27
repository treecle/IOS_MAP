//
//  Extensions.swift
//  wbs
//
//  Created by Home on 05/11/2019.
//  Copyright © 2019 Sidory. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    /// 단말의 Safe Area Inset값을 가져온다.
    func getSafeAreaInsets() -> UIEdgeInsets {
        if isiPhoneXseries() {
            if #available(iOS 11.0, *),
                let window = UIApplication.shared.windows.first {
                return window.safeAreaInsets
            }
        }
        return .zero
    }
    
    func openApp(urlStr: String) {
        guard let url = URL.init(string: urlStr) else {
            return
        }
        
        let application = UIApplication.shared
        if application.canOpenURL(url) {
            application.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension UIColor {
    /// 16진수 색상 추출
    static func getColor(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
