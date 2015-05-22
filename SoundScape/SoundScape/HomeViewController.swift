//
//  ViewController.swift
//  SoundScape
//
//  Created by Prasath Thurgam on 5/12/15.
//  Copyright (c) 2015 samsung. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController {
    
    
    var mainViewController: QueueTableViewController? = nil;

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //btnAction.addTarget(self, action: Selector("showCastMenuView"), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        // Add an observer to check if a tv is connected
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serviceConnected", name: multiScreenManager.serviceConnectedObserverIdentifier, object: nil)
        
        // Add an observer to check for services status
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "servicesChanged", name: multiScreenManager.servicesChangedObserverIdentifier, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissQueueVC", name: multiScreenManager.dismissQueueVCObserverIdentifier, object: nil)

        
    }
    
    override func viewWillAppear(animated: Bool) {
        activitySearching.startAnimating()
        btnAction.hidden = true
        lblDevices.text = " "
        multiScreenManager.startSearching()
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector:  Selector("searchTimerFired"), userInfo: nil, repeats: false)
        
        
        
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: multiScreenManager.serviceConnectedObserverIdentifier, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: multiScreenManager.servicesChangedObserverIdentifier, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: multiScreenManager.dismissQueueVCObserverIdentifier, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var activitySearching: UIActivityIndicatorView!
    
    @IBOutlet weak var lblDevices: UILabel!
    
    @IBOutlet weak var btnAction: UIButton!
    
    @IBAction func actionButtonPressed(sender: AnyObject) {
        if btnAction.titleLabel!.text == "Select" {
            showCastMenuView()
        } else if btnAction.titleLabel!.text == "Connect" {
            if multiScreenManager.services.count >= 1 {
                multiScreenManager.createApplication(multiScreenManager.services[0], completionHandler: { [unowned self](success: Bool!) -> Void in
                    if ((success) == false){
                        var  alertView:UIAlertView = UIAlertView(title:"", message: "Connection could not be established", delegate: self, cancelButtonTitle: "OK")
                        alertView.alertViewStyle = .Default
                        alertView.show()
                    } else {
                        //NSNotificationCenter.defaultCenter().postNotificationName(self.multiScreenManager.serviceSelectedObserverIdentifier, object: self)
                    }
                    })
            }
            
        } else if btnAction.titleLabel!.text == "Information" {
            let informationNavigationViewController = self.storyboard?.instantiateViewControllerWithIdentifier("InformationNavigationController") as? UIViewController
            informationNavigationViewController!.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            presentViewController(informationNavigationViewController!, animated: true, completion: nil)
   
        }
    }
    func searchDevices() {
        
    }
    
    
    /*
    /// Shows a list of available services
    /// User can connect to a service
    /// User can disconnect from a connected service
    func showCastMenuView() {
        
        /// UIView that contains a list of available services
        var viewArray = NSBundle.mainBundle().loadNibNamed("ServicesView", owner: self, options: nil)
        servicesView = viewArray[0] as! ServicesView
        servicesView.frame = UIScreen.mainScreen().bounds
        
        /// Adding UIVIew to superView
        addUIViewToWindowSuperView(servicesView)

        
        /*
        //performSegueWithIdentifier("showPlayList", sender: self)
        
        mainViewController = self.storyboard?.instantiateViewControllerWithIdentifier("QueueTableViewControllerID") as? UIViewController
        mainViewController!.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        presentViewController(mainViewController!, animated: true, completion: nil)
        */
    }
    */
    func searchTimerFired() {
        setupView()
    }
    
    func serviceSelected() {
        if (mainViewController != nil) {
            println("ERROR - Check")
        } else {
            mainViewController = self.storyboard?.instantiateViewControllerWithIdentifier("QueueTableViewControllerID") as? QueueTableViewController
            mainViewController!.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            presentViewController(mainViewController!, animated: true, completion: nil)
        }
    }
    
    func serviceConnected() {
        if (mainViewController != nil) {
            //mainViewController?.setupView()
            return
        } else {
            mainViewController = self.storyboard?.instantiateViewControllerWithIdentifier("QueueTableViewControllerID") as? QueueTableViewController
            mainViewController!.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            presentViewController(mainViewController!, animated: true, completion: nil)
        }
        //dismissQueueVC()
        
    }
    
    func servicesChanged() {
        setupView()
        /*
        if (!multiScreenManager.isConnected) {
            mainViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
*/
    }
    
    func setupView() {
        activitySearching.stopAnimating()
        
        if (multiScreenManager.services.count == 1 ) {
            lblDevices.text = "Discovered \"\(multiScreenManager.services[0].name)\""
            btnAction.setTitle("Connect", forState: UIControlState.Normal)
        } else if (multiScreenManager.services.count > 1 ) {
            lblDevices.text = "Found \(multiScreenManager.services.count) devices "
            btnAction.setTitle("Select", forState: UIControlState.Normal)
        } else {
            lblDevices.text = "No devices discovered"
            btnAction.setTitle("Information", forState: UIControlState.Normal)
            activitySearching.startAnimating()
        }
        btnAction.hidden = false
    }
    
    func dismissQueueVC() {
        mainViewController?.dismissViewControllerAnimated(true, completion: nil)
        mainViewController = nil
    }
}
