//
//  InformationViewController.swift
//  SoundScape
//
//  Created by Prasath Thurgam on 5/21/15.
//  Copyright (c) 2015 samsung. All rights reserved.
//

import UIKit

class InformationViewController: UIViewController {
    
    @IBOutlet weak var informationWebView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let localfilePath = NSBundle.mainBundle().URLForResource("Information", withExtension: "html");
        let html = NSString(contentsOfURL: localfilePath!, encoding: NSUTF8StringEncoding, error: nil)
    
        var ssid: String? = String(SSIdInfo.currentWifiSSID())
        var ssidDisplay: String = String()
        
        if ssid != nil {
            ssidDisplay = ssid!
        } else {
            ssidDisplay = "your network"
        }
        
        let htmlString = html?.stringByReplacingOccurrencesOfString("%%SSID%%", withString: ssidDisplay) as String?
        informationWebView.loadHTMLString(htmlString, baseURL: nil)
    }

    @IBAction func dismissInformationVC(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
