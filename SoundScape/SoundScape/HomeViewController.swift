//
//  ViewController.swift
//  SoundScape
//
//  Created by Prasath Thurgam on 5/12/15.
//  Copyright (c) 2015 samsung. All rights reserved.
//

import UIKit


class HomeViewController: UIViewController, UIPopoverPresentationControllerDelegate{
    
    
    var mainViewController: QueueTableViewController? = nil;

    /// MultiScreenManager instance that manages the interaction with the services
    var multiScreenManager = MultiScreenManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //btnAction.addTarget(self, action: Selector("showCastMenuView"), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        // Add an observer to check if a tv is connected
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serviceConnected", name: multiScreenManager.serviceConnectedObserverIdentifier, object: nil)
        
        // Add an observer to check for services status
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "servicesChanged", name: multiScreenManager.servicesChangedObserverIdentifier, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissQueueVC", name: multiScreenManager.dismissQueueVCObserverIdentifier, object: nil)
        
        btnAction.layer.cornerRadius = 5
        btnAction.layer.borderWidth = 0.5
        btnAction.layer.borderColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1).CGColor
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
            //showCastMenuView()
            showDevices()
        } else if btnAction.titleLabel!.text == "Connect" {
            if multiScreenManager.services.count >= 1 {
                multiScreenManager.createApplication(multiScreenManager.services[0], completionHandler: { [unowned self](success: Bool!) -> Void in
                    if ((success) == false){
                        var  alertView:UIAlertView = UIAlertView(title:"", message: "Connection could not be established", delegate: self, cancelButtonTitle: "OK")
                        alertView.alertViewStyle = .Default
                        alertView.show()
                    } else {
                        //NSNotificationCenter.defaultCenter().postNotificationName(self.multiScreenManager.serviceSelectedObserverIdentifier, object: self)
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(self.multiScreenManager.serviceConnectedObserverIdentifier, object: self)
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
        /*
        mainViewController?.dismissViewControllerAnimated(true, completion: nil)
        mainViewController = nil
*/
        self.dismissViewControllerAnimated(true, completion: nil)
        mainViewController = nil
    }
    
    func showDevices() {
        
        let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("DevicesViewController") as! UIViewController
        //popoverVC.modalPresentationStyle = .Popover
        
        popoverVC.modalTransitionStyle = .CrossDissolve
        popoverVC.view.backgroundColor = UIColor.clearColor()
        
        popoverVC.modalPresentationStyle = .OverCurrentContext
        
        let blurEffect: UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let beView: UIVisualEffectView = UIVisualEffectView(effect: blurEffect)
        beView.tag = 1
        beView.frame = self.view.bounds;
        beView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        popoverVC.view.frame = self.view.bounds
        popoverVC.view.insertSubview(beView, atIndex: 0)
        popoverVC.view.tag = 1
        // Present it before configuring it
        presentViewController(popoverVC, animated: true, completion: nil)
        
        
        // Now the popoverPresentationController has been created
        if let popoverController = popoverVC.popoverPresentationController {
            //popoverController.sourceView = sender
            //popoverController.sourceRect = sender.bounds
            //popoverController.permittedArrowDirections = .Any
            //popoverController.delegate = self
        }
        
    }
}
