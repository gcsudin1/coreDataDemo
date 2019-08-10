//
//  ViewController.swift
//  coreDataDemo
//
//  Created by IMCS2 on 8/6/19.
//  Copyright © 2019 IMCS2. All rights reserved.
//

import UIKit
import WebKit
import Network

class ViewController: UIViewController {
    let monitor = NWPathMonitor()
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var webView: WKWebView!
    var blogUrlArray = ""
    var headingArray = String()
    
    override func viewWillAppear(_ animated: Bool) {
        textView.text = headingArray
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let update = "https" + blogUrlArray.dropFirst(4)
        let url = NSURL(string: update)
        let urlreq = URLRequest(url: url! as URL)
        webView.load(urlreq)
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("We are connected!")
            } else {
                print("No connection.")
                DispatchQueue.main.async {
                    self.webView.loadHTMLString("<html><body><h1> Unable to display the URL \(url!) check your internet connection</h1></body></html>", baseURL: nil)
                }
            }
            print(path.isExpensive)
        }
        let queue = DispatchQueue(label:"Monitor")
        monitor.start(queue:queue)
    }
}

