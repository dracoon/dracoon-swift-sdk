//
//  OAuthWebView.swift
//  SDSApp
//
//  Created by Mathias Schreiner on 17.09.18.
//  Copyright © 2018 SSP Europe GmbH. All rights reserved.
//

import UIKit
import WebKit
import dracoon_sdk

protocol OAuthWebViewDelegate: class {
    func receivedCode(code: String)
}

class OAuthWebView: UIViewController, WKNavigationDelegate {
    
    weak var delegate: OAuthWebViewDelegate?
    var webView: WKWebView!
    var state: String?
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.requestAuthorization()
    }
    
    fileprivate func requestAuthorization() {
        guard let serverUrl = URL(string: OAuthConfig.serverUrl) else {
            print("Set OAuth configuration in OAuthConfig class before using this example")
            return
        }
        
        let state = UUID().uuidString
        
        let authorizationURL = OAuthHelper.createAuthorizationUrl(serverUrl: serverUrl, clientId: OAuthConfig.clientId, state: state, deviceName: nil)
        
        var authorizationRequest = URLRequest(url: authorizationURL)
        authorizationRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        authorizationRequest.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        authorizationRequest.addValue(OAuthHelper.createBasicAuthorizationString(clientId: OAuthConfig.clientId, clientSecret: OAuthConfig.clientSecret), forHTTPHeaderField: "Authorization")
        
        self.state = state
        
        webView.load(authorizationRequest)
    }
    
    
    // MARK: WKNavigationDelegate
    
    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        let request = navigationAction.request
        self.handleAuthorizationResponse(request: request, decisionHandler: decisionHandler)
    }
    
    func handleAuthorizationResponse(request: URLRequest, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        guard let url = request.url,
            url.scheme == OAuthConfig.redirectURI.scheme,
            url.host == OAuthConfig.redirectURI.host,
            let responseState = OAuthHelper.extractAuthorizationState(fromUrl: url), responseState == self.state,
            let code = OAuthHelper.extractAuthorizationCode(fromUrl: url) else {
                decisionHandler(.allow)
                return
        }
        
        delegate?.receivedCode(code: code)
        decisionHandler(.cancel)
    }
}

