//
//  ViewController.swift
//  TreecleMap
//
//  Created by Yee on 2021/08/12.
//

import UIKit
import WebKit
import OneSignal
import AuthenticationServices

class ViewController: UIViewController {
    
    /// Splash View
    var splashView: SplashView?
    /// WkWebView 객체
    var webView: BaseWebView!
    /// WebView가 올라갈 베이스 뷰
    @IBOutlet weak var baseView: UIView!
    
    private var refreshControl = UIRefreshControl()
    
    private let progressView = UIProgressView(progressViewStyle: .default)
    
    private var estimatedProgressObserver: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 웹뷰 초기화
        self.webView = BaseWebView(frame: .zero, configuration: WKWebViewConfiguration(), target: self)

        // 스플래쉬뷰
        showSplashView()
        // 프로그레스바
        setupProgressView()
        // 프로그래스바 옵져버
        setupEstimatedProgressObserver()
        
        // 웹뷰 로드
        loadWebView(urlString: Const.Url.home.name)
        
    }
    
    /// WebVeiw load
    private func loadWebView(urlString: String) {
        guard let url = URL.init(string: urlString) else { return }
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.baseView.addSubview(self.webView)
        self.webView.setAutolayout(withView: self.baseView)
        
        
        // 당겨서 새로고침
//        setRefreshControl()
        
        var webRequest = URLRequest(url: url)
        let cookies = HTTPCookie.requestHeaderFields(with: HTTPCookieStorage.shared.cookies(for: webRequest.url!)!)
        if let value = cookies["Cookie"] {
            webRequest.addValue(value, forHTTPHeaderField: "Cookie")
        }
        
        self.webView.load(webRequest)
    }
    
    
    func reloadURL(_ pushURL: String) {
        guard let url = URL.init(string: pushURL) else { return }
        var request = URLRequest.init(url: url)
        request.httpShouldHandleCookies = true
        self.webView.load(request)
    }
    
    /// 스플래시 qb 띄우기 - 1.5초
    private func showSplashView() {
        self.splashView = SplashView(frame: self.view.frame)
        self.view.addSubview(self.splashView!)
        self.splashView?.startAnimation()
    }
    
    /// 스플래시 사라지게
    private func hideSplashView() {
        if let splashView = self.splashView {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    splashView.alpha = 0.0
                }) { (success) in
                    splashView.removeFromSuperview()
                }
            }
        }
    }
    
    /// 당겨서 새로고침을 위한 refresh Control
    private func setRefreshControl() {
        self.refreshControl.addTarget(self, action: #selector(self.refreshWebView(refreshControl:)), for: UIControl.Event.valueChanged)
        self.webView.scrollView.addSubview(self.refreshControl)
        self.webView.scrollView.bounces = true
    }
    
    @objc private func refreshWebView(refreshControl: UIRefreshControl){
        refreshControl.beginRefreshing()
        self.webView.reload()
    }
    
    private func setupProgressView() {

        progressView.translatesAutoresizingMaskIntoConstraints = false
        self.baseView.addSubview(progressView)
        
        progressView.isHidden = true
        
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            
            progressView.bottomAnchor.constraint(equalTo: self.baseView.topAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2.0)
            ])
    }
    
    private func setupEstimatedProgressObserver() {
        estimatedProgressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            self?.progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    public func setPushID() {
        self.webView.evaluateJavaScript("localStorage.getItem(\"push_treecle_id\")") { (result, error) in
            print("pushToken = \(result as? String ?? " Empty ")")
            if result as? String == nil {
                let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                if status.permissionStatus.status == .notDetermined || status.permissionStatus.status == .denied { return }
                guard let pushToken = status.subscriptionStatus.userId else { return }
                print("pushToken = \(pushToken)")
                self.webView.evaluateJavaScript("localStorage.setItem(\"push_treecle_id\", '" + pushToken + "')") { (result, error) in
                }
            }
        }
    }
}


// MARK:- WKUIDelegate
extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else {
            return nil
        }
        // target = _blank tag 호출시
        guard let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame  else  {
            self.webView.openApp(withScheme: url.absoluteString, moreString: nil)
            return nil
        }
        return nil
    }
    
    // JavaScript 확인 얼럿
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Const.Text.confirm.name, style: .default, handler: { (action) in
            completionHandler()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // JAvaScript 확인/취소 얼럿
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Const.Text.confirm.name, style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: Const.Text.cancel.name, style: .cancel, handler: { (action) in
            completionHandler(false)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // JAvaScript TextField 얼럿
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: frame.request.url?.host, message: prompt, preferredStyle: .alert)
        weak var alertTextField: UITextField!
        alertController.addTextField { textField in
            textField.text = defaultText
            alertTextField = textField
        }
        alertController.addAction(UIAlertAction(title: Const.Text.cancel.name, style: .cancel, handler: { action in
            completionHandler(nil)
        }))
        alertController.addAction(UIAlertAction(title: Const.Text.confirm.name, style: .default, handler: { action in
            completionHandler(alertTextField.text)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK:- WKNavigationDelegate
extension ViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        debug("navigationAction")
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        let urlStr = url.absoluteString
        debug("Url : " + urlStr)
        
        /// 특정 앱 스킴에 동작 (전화, 이메일, 문자 등)
        let urlElements = urlStr.components(separatedBy: ":")
        switch urlElements[0] {
            
        case "tel", "sms", "mailto", "itmss" :
            self.webView.openApp(withScheme: urlStr, moreString: nil)
            decisionHandler(.cancel)
            return
            
        case "http", "https":
            break
            
        default:
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            } else {
                break
            }
        }
        
        decisionHandler(.allow)
    }
    
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        preferences.preferredContentMode = .mobile
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel, preferences)
            return
        }
        
        let urlStr = url.absoluteString
        debug("Url : " + urlStr)
        
        /// 특정 앱 스킴에 동작 (전화, 이메일, 문자 등)
        let urlElements = urlStr.components(separatedBy: ":")
        switch urlElements[0] {
            
        case "tel", "sms", "mailto", "itmss" :
            self.webView.openApp(withScheme: urlStr, moreString: nil)
            decisionHandler(.cancel, preferences)
            return
            
        case "http", "https":
            break
            
        default:
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel, preferences)
                return
            } else {
                break
            }
        }
        
        decisionHandler(.allow, preferences)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        debug("navigationResponse")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        debug("didStartProvisionalNavigation")

        if progressView.isHidden {
            // Make sure our animation is visible.
            progressView.isHidden = false
        }
        
        UIView.animate(
            withDuration: 0.33,
            animations: {
                self.progressView.alpha = 1.0
        })
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        debug("didCommit")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 웹뷰에서 롱클릭에 대한 이벤트를 막아준다.
        debug("didFinish")
        webView.evaluateJavaScript("document.body.style.webkitTouchCallout='none';")

        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        UIView.animate(
            withDuration: 0.33,
            animations: {
                self.progressView.alpha = 0.0
        },
            completion: { isFinished in
                self.progressView.isHidden = isFinished
        })
        
        setPushID()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        debug("Error WebView : \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        debug("didReceive")
        switch (challenge.protectionSpace.authenticationMethod) {
        case NSURLAuthenticationMethodHTTPBasic:
            let alertController = UIAlertController(title: "Authentication Required", message: webView.url?.host, preferredStyle: .alert)
            weak var usernameTextField: UITextField!
            alertController.addTextField { textField in
                textField.placeholder = "Username"
                usernameTextField = textField
            }
            weak var passwordTextField: UITextField!
            alertController.addTextField { textField in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
                passwordTextField = textField
            }
            alertController.addAction(UIAlertAction(title: Const.Text.cancel.name, style: .cancel, handler: { action in
                completionHandler(.cancelAuthenticationChallenge, nil)
            }))
            alertController.addAction(UIAlertAction(title: Const.Text.confirm.name, style: .default, handler: { action in
                guard let username = usernameTextField.text, let password = passwordTextField.text else {
                    completionHandler(.rejectProtectionSpace, nil)
                    return
                }
                let credential = URLCredential(user: username, password: password, persistence: URLCredential.Persistence.forSession)
                completionHandler(.useCredential, credential)
            }))
            present(alertController, animated: true, completion: nil)
            
        default:
            completionHandler(.rejectProtectionSpace, nil);
        }
    }
}

// MARK:- WKScriptMessageHandler
extension ViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // 웹에서 Javascript로 iOS Method를 호출 할 수 있다.
        // if message.name == "웹과 통신할 키값" { }
        if message.name == BaseWebView.REQUEST_APPLE_LOGIN {
            requestAppleIdLogin()
        } else if message.name == BaseWebView.REQUEST_OPEN,
            let url = message.body as? String {
            self.openApp(urlStr: url)
        }
    }
    
    /// Apple ID 로그인 연동 시도 함수
    private func requestAppleIdLogin() {
        if #available(iOS 13.0, *) {
            if let appleUserId = UserDefaults.standard.object(forKey: BaseWebView.APPLE_LOGIN_USER_ID) as? String,
                appleUserId.isEmpty == false {
                // 등록된 Apple ID가 있는 경우
                perfomExistingAccountSetupFlows()
            } else {
                // Apple ID가 없는 경우

                // A mechanism for generating requests to authenticate users based on their Apple ID.
                let appleIDProvider = ASAuthorizationAppleIDProvider()

                // Creates a new Apple ID authorization request.
                let request = appleIDProvider.createRequest()

                // The contact information to be requested from the user during authentication.
                request.requestedScopes = [.fullName, .email]

                // A controller that manages authorization requests created by a provider.
                let controller = ASAuthorizationController(authorizationRequests: [request])

                // A delegate that the authorization controller informs about the success or failure of an authorization attempt.
                controller.delegate = self

                // A delegate that provides a display context in which the system can present an authorization interface to the user.
                controller.presentationContextProvider = self

                // starts the authorization flows named during controller initialization.
                controller.performRequests()
            }
        } else {
            // iOS 13미만은 팝업 노출
            let alertVC = UIAlertController(title: "알림", message: "애플로그인은 iOS 13버전부터 사용가능합니다. 소프트웨어를 업데이트하세요", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }
    }
}


// MARK:- ASAuthorizationControllerDelegate & ASAuthorizationControllerPresentationContextProviding
extension ViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // Apple ID 로그인 성공
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            if let token = appleIDCredential.identityToken, token.isEmpty == false,
                let userToken = String(bytes: token, encoding: .utf8) {
                
                
                self.webView.evaluateJavaScript("setAppleLoginUserToken(\'" + userToken + "')") { (result, error) in
                    print("User Token = \(result as? String ?? " Empty ")")
                }
                
            }
            
            UserDefaults.standard.set(userIdentifier, forKey: BaseWebView.APPLE_LOGIN_USER_ID)
        }
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 인증 실패
    }
    
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func perfomExistingAccountSetupFlows() {
        if #available(iOS 13.0, *) {
            guard let appleUserId = UserDefaults.standard.object(forKey: BaseWebView.APPLE_LOGIN_USER_ID) as? String else {
                return
            }
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: appleUserId) { (state, error) in
                if state == .revoked {
                    UserDefaults.standard.set("", forKey: BaseWebView.APPLE_LOGIN_USER_ID)
                    
                    let appleIDProvider = ASAuthorizationAppleIDProvider()
                    let request = appleIDProvider.createRequest()
                    request.requestedScopes = [.fullName, .email]
                    let controller = ASAuthorizationController(authorizationRequests: [request])
                    controller.delegate = self
                    controller.presentationContextProvider = self
                    controller.performRequests()
                } else if state == .authorized {

                    let appleIDProvider = ASAuthorizationAppleIDProvider()
                    let request = appleIDProvider.createRequest()
                    
                    let controller = ASAuthorizationController(authorizationRequests: [request])
                    controller.delegate = self
                    controller.presentationContextProvider = self
                    controller.performRequests()
                    
                } else if state == .notFound {
                    UserDefaults.standard.set("", forKey: BaseWebView.APPLE_LOGIN_USER_ID)
                }
            }
        }
    }
}




