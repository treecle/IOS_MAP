//
//  Constants.swift
//  wbs
//
//  Created by Home on 05/11/2019.
//  Copyright © 2019 Sidory. All rights reserved.
//

import Foundation

enum Const{}

//MARK:- Text
extension Const {
    enum Text: String { case
        notice = "알림",
        confirm = "확인",
        cancel = "취소"
        
        var name: String { return self.rawValue }
    }
}

//MARK:- Url
extension Const {
    enum Url: String { case
        home = "https://treecle.io/map/"
        var name: String { return self.rawValue }
    }
}
