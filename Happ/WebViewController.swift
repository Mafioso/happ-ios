//
//  WebViewController.swift
//  Happ
//
//  Created by Yernar Mailyubayev on 27.11.16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var WebView: UIWebView!

    var link: String!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backimage = UIImage(named: "nav-back-gray")!
        let newBackButton = UIBarButtonItem(image: backimage,  style: .Plain, target: self, action: #selector(self.handleGoBack))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        let url = NSURL(string: self.link)!
        let request = NSURLRequest(URL: url)
        self.WebView.loadRequest(request)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.extMakeNavBarWhite()
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.extMakeNavBarVisible()
    }
    
    func sayHello() {
        print("hello")
    }
    
    func handleGoBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    
}
