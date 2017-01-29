//
//  WebViewController.swift
//  Happ
//
//  Created by Yernar Mailyubayev on 27.11.16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import WebKit



class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    var webView: WKWebView!
    var progressView: UIProgressView!
    var link: String!


    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.UIDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = .None

        self.initNavBarItems()
        self.initWebView()
        self.initHandleWebViewProgress()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.extMakeNavBarWhite()
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.extMakeNavBarVisible()
    }
    deinit {
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }


    func handleGoBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.title") { result, error in
            if let title = result as? String {
                self.setNavBarTitle(title)
            }
        }
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "estimatedProgress" {
            let value = Float(self.webView.estimatedProgress)
            self.progressView.progress = value
            if value >= 1 {
                UIView.animateWithDuration(0.3, animations: {
                    self.progressView.hidden = true
                }, completion: nil)
            }
        }
    }


    private func initNavBarItems() {
        let backimage = UIImage(named: "nav-back-gray")!
        let newBackButton = UIBarButtonItem(image: backimage,  style: .Plain, target: self, action: #selector(self.handleGoBack))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    private func initWebView() {
        let url = NSURL(string: self.link)!
        let request = NSURLRequest(URL: url)
        self.webView.loadRequest(request)
    }
    private func setNavBarTitle(title: String) {
        self.navigationItem.title = title
    }
    private func initHandleWebViewProgress() {
        self.progressView = {
            let p = UIProgressView(progressViewStyle: .Default)
            let width = UIScreen.mainScreen().bounds.width
            p.frame = CGRectMake(0, 0, width, p.frame.height)
            p.progressTintColor = UIColor.happOrangeColor()
            self.view.addSubview(p)
            return p
        }()

        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
    }

}


