//
//  InitialViewController.swift
//  oauth2.example
//
//  Created by Mathias Schreiner on 08.11.18.
//  Copyright © 2018 Dracoon. All rights reserved.
//

import UIKit
import dracoon_sdk

class InitialViewController: UIViewController, OAuthWebViewDelegate, OAuthTokenChangedDelegate {
    
    var webView: OAuthWebView?
    var client: DracoonClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setupButton()
    }
    
    fileprivate func setupButton() {
        let button = UIButton()
        button.setTitle("LOGIN", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.layer.cornerRadius = 5
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(startLogin), for: .touchUpInside)
        
        
        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func startLogin() {
        self.openWebView()
    }
    
    fileprivate func openWebView() {
        let webView = OAuthWebView()
        webView.delegate = self
        self.webView = webView
        self.present(webView, animated: false, completion: nil)
    }
    
    fileprivate func setupDracoonClient(authCode: String) {
        let authMode = DracoonAuthMode.authorizationCode(clientId: OAuthConfig.clientId, clientSecret: OAuthConfig.clientSecret, authorizationCode: authCode)
        let client = DracoonClientImpl(serverUrl: URL(string: OAuthConfig.serverUrl)!, authMode: authMode, getEncryptionPassword: getEncryptionPassword, oauthCallback: self)
        self.client = client
    }
    
    fileprivate func getEncryptionPassword() -> String? {
        // TODO retrieve and return password
        return nil
    }
    
    fileprivate func openNodesView() {
        guard let client = self.client else {
            return
        }
        let nodesViewController = NodeTableViewController(client: client)
        let navigationController = UINavigationController(rootViewController: nodesViewController)
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - OAuth webview delegate
    
    func receivedCode(code: String) {
        self.webView?.dismiss(animated: false, completion: nil)
        self.setupDracoonClient(authCode: code)
    }
    
    // MARK:  - OAuth token changed delegate
    
    func tokenChanged(accessToken: String, refreshToken: String) {
        // TODO store tokens
        self.openNodesView()
    }
}
