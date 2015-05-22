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
        let myRequest = NSURLRequest(URL: localfilePath!);
        informationWebView.loadRequest(myRequest);
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
