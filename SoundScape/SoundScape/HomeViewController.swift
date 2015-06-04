//
//  ViewController.swift
//  SoundScape
//
//  Created by Prasath Thurgam on 5/12/15.
//  Copyright (c) 2015 samsung. All rights reserved.
//

import UIKit
import MSF

class HomeViewController: UIViewController, UIPopoverPresentationControllerDelegate{
    
    
    var mainViewController: QueueTableViewController? = nil;

    /// MultiScreenManager instance that manages the interaction with the services
    var multiScreenManager = MultiScreenManager.sharedInstance
    
    var ssid: String? = String()

    var reachabilityForWifi = Reachability.reachabilityForLocalWiFi()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //btnAction.addTarget(self, action: Selector("showCastMenuView"), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        // Add an observer to check if a tv is connected
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serviceConnected", name: multiScreenManager.serviceConnectedObserverIdentifier, object: nil)
        
        // Add an observer to check for services status
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "servicesChanged", name: multiScreenManager.servicesChangedObserverIdentifier, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissQueueVC", name: multiScreenManager.dismissQueueVCObserverIdentifier, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: kReachabilityChangedNotification, object: nil)
        
        btnAction.layer.cornerRadius = 5
        btnAction.layer.borderWidth = 0.5
        btnAction.layer.borderColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1).CGColor
        
        ssid = SSIdInfo.currentWifiSSID()
        reachabilityForWifi.startNotifier()
        
        //activitySearching.startAnimating()
    }
    
    override func viewWillAppear(animated: Bool) {
        //activitySearching.startAnimating()
        
        btnAction.hidden = true
        lblDevices.text = " "
        multiScreenManager.startSearching()
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector:  Selector("searchTimerFired"), userInfo: nil, repeats: false)
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: multiScreenManager.serviceConnectedObserverIdentifier, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: multiScreenManager.servicesChangedObserverIdentifier, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: multiScreenManager.dismissQueueVCObserverIdentifier, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kReachabilityChangedNotification, object: nil)
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
                
                var text: String = String("connecting to ")
                
                var hud = MBProgressHUD(view: self.view)
                let cgFloat: CGFloat = CGRectGetMinY(self.view.bounds);
                let someFloat: Float = Float(cgFloat)
                hud.yOffset = someFloat
                self.view.addSubview(hud)
                
                let toastMsg =  String("connecting to ") + (multiScreenManager.services[0] as Service).displayName
                
                hud.labelText = toastMsg
                hud.show(true)
                hud.dimBackground = true
                
                multiScreenManager.createApplication(multiScreenManager.services[0], completionHandler: { [unowned self](success: Bool!) -> Void in
                    hud.hide(true)
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
   
        } else if btnAction.titleLabel!.text == "Settings"{
            UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!);
        }
    }
    
    func searchTimerFired() {
        activitySearching.stopAnimating()
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
        dismissQueueVC()
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
        //activitySearching.stopAnimating()
        ssid = SSIdInfo.currentWifiSSID()
        var ssidDisplay: String = String()
        
        if ssid != nil {
            ssidDisplay = ssid!
        } else {
            ssidDisplay = "your network"
        }
        
        if self.reachabilityForWifi.currentReachabilityStatus().value != ReachableViaWiFi.value {
            lblDevices.text = "WiFi is not connected"
            btnAction.setTitle("Settings", forState: UIControlState.Normal)
        } else if (multiScreenManager.services.count == 1 ) {
            lblDevices.text = "Discovered \(multiScreenManager.services[0].displayName) on \"\(ssidDisplay)\""
            btnAction.setTitle("Connect", forState: UIControlState.Normal)
        } else if (multiScreenManager.services.count > 1 ) {
            lblDevices.text = "Found \(multiScreenManager.services.count) devices on \"\(ssidDisplay)\""
            btnAction.setTitle("Select", forState: UIControlState.Normal)
        } else {
            lblDevices.text = "No devices discovered on \"\(ssidDisplay)\""
            btnAction.setTitle("Information", forState: UIControlState.Normal)
            //activitySearching.startAnimating()
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
            //popoverController.sourceView = self.view
            //popoverController.sourceRect = self.view.bounds
            //popoverController.permittedArrowDirections = .Any
            //popoverController.delegate = self
        }
    }
    
    func reachabilityChanged(notification: NSNotification) {
        self.reachabilityForWifi = notification.object as? Reachability
        setupView()
    }
}
