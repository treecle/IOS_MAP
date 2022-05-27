//
//  BaseWebView.swift
//  AnimalGo
//
//  Created by Kiwon on 16/07/2019.
//  Copyright © 2019 AnimalGo. All rights reserved.
//

import UIKit
import WebKit

class BaseWebView: WKWebView {
    // iOS UserAgent
    private let CUSTOM_USER_AGENT = "ios_treecleamap"
    static let REQUEST_APPLE_LOGIN = "requestAppleLogin"
    static let REQUEST_OPEN = "requestOpen"
    static let APPLE_LOGIN_USER_ID = "appleLoginUserID"
    
    init(frame: CGRect, configuration: WKWebViewConfiguration, target: ViewController) {
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        let userController: WKUserContentController = WKUserContentController()
        
        // Javascript로 iOS Method를 호출하기 위한 handler 설정
        userController.add(target, name: BaseWebView.REQUEST_APPLE_LOGIN)
        userController.add(target, name: BaseWebView.REQUEST_OPEN)

        // iOS 결제앱을 불러오기 위해 앱 Scheme값을 웹으로 전달한다.
        //            let userScript = WKUserScript(
        //                source: "shcemeIos('ciangsiosforjunior://')",
        //                injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
        //                forMainFrameOnly: true
        //            )
        //            userController.addUserScript(userScript)
        
        configuration.userContentController = userController;
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        
        super.init(frame: frame, configuration: configuration)
        setupWebView()
        self.customUserAgent = "\(self.CUSTOM_USER_AGENT)"
//        let _ = getUserAgent { (string) in
//            // Mozilla/5.0 (iPhone; CPU iPhone OS 12_1_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Mobile/15E148 Safari/604.1 APP_WBSI_iOS
//            if let userAgent = string {
//
//            }
//        }
    }
    
    convenience init(target: ViewController) {
        self.init(frame: .zero, configuration: WKWebViewConfiguration(), target: target)
        setupWebView()
    }
    
    
    private func getUserAgent(completion: @escaping (_ titleString: String?) -> Void) {
       self.evaluateJavaScript("navigator.userAgent", completionHandler: { (innerHTML, error ) in
            completion(innerHTML as? String)
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK:- Public Functions
extension BaseWebView {
    
    /// 오토레이아웃 설정
    func setAutolayout(withView view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    /// 특정 Scheme으로 이동 (전화, 메일 등 )
    func openApp(withScheme urlScheme: String, moreString: String?) {
        guard let url = URL.init(string: urlScheme + (moreString ?? "")) else {
            return
        }
        
        let application = UIApplication.shared
        if application.canOpenURL(url) {
            application.open(url, options: [:], completionHandler: nil)
        }
    }

    /// 내부 캐시 삭제
    func deleteCache() {
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        let date = NSDate(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
    }
}

// MARK:- Private Functions
extension BaseWebView {
    private func setupWebView() {
        // 배경색
        self.backgroundColor = .white
        self.scrollView.backgroundColor = .white
        self.allowsBackForwardNavigationGestures = true
        
        // 스크롤바 나타난지 않음.
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        // 바운싱 없음
        self.scrollView.bounces = false
        
        // 더블 텝 줌 없음
        self.scrollView.bouncesZoom = false
    }
}
