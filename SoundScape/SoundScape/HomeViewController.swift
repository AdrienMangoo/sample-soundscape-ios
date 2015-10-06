/*

Copyright (c) 2014 Samsung Electronics

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

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
    }
    
    override func viewWillAppear(animated: Bool) {
        btnAction.hidden = true
        self.lblDevices.text = "Searching for devices...."
        multiScreenManager.startSearching()
        
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector:  Selector("searchTimerFired"), userInfo: nil, repeats: false)
        
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
            showDevices()
        } else if btnAction.titleLabel!.text == "Connect" {
            if multiScreenManager.services.count >= 1 {
                
                let hud = MBProgressHUD(view: self.view)
                let cgFloat: CGFloat = CGRectGetMinY(self.view.bounds);
                let someFloat: Float = Float(cgFloat)
                hud.yOffset = someFloat
                self.view.addSubview(hud)
                
                let toastMsg =  String("connecting to ") + (multiScreenManager.services[0] as Service).displayName
                
                hud.labelText = toastMsg
                hud.show(true)
                hud.dimBackground = true
                
                multiScreenManager.createApplication(multiScreenManager.services[0], completionHandler: { [unowned self](success: Bool!, error: NSError?) -> Void in
                    hud.hide(true)
                    if ((success) == false){
                        var errorMsg: String? = String()
                        if error != nil {
                            errorMsg = error!.localizedDescription
                        } else {
                            errorMsg = "Connection could not be established"
                        }
                        let alertView:UIAlertView = UIAlertView(title:"", message: errorMsg, delegate: self, cancelButtonTitle: "OK")
                        alertView.alertViewStyle = .Default
                        alertView.show()
                    } else {
                        NSNotificationCenter.defaultCenter().postNotificationName(self.multiScreenManager.serviceConnectedObserverIdentifier, object: self)
                    }
                    })
            }
        } else if btnAction.titleLabel!.text == "Information" {
            let informationNavigationViewController = self.storyboard?.instantiateViewControllerWithIdentifier("InformationNavigationController")
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
    
    /// called when you connect to a Service
    ///
    func serviceConnected() {
        dismissQueueVC()
        if (mainViewController != nil) {
            return
        } else {
            mainViewController = self.storyboard?.instantiateViewControllerWithIdentifier("QueueTableViewControllerID") as? QueueTableViewController
            mainViewController!.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            presentViewController(mainViewController!, animated: true, completion: nil)
        }
    }
    /// avaliable services list has changes
    ///
    func servicesChanged() {
        setupView()
    }
    
    /// sets up the view
    ///
    func setupView() {

        if (multiScreenManager.isConnected) {
            btnAction.hidden = true
            lblDevices.text = ""
            return
        }
        ssid = SSIdInfo.currentWifiSSID()
        var ssidDisplay: String = String()
        
        if ssid != nil {
            ssidDisplay = ssid!
        } else {
            ssidDisplay = "your network"
        }
        
        if self.reachabilityForWifi.currentReachabilityStatus().rawValue != ReachableViaWiFi.rawValue {
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
    /// dismisses the Queue/PlayList View Controller
    ///
    func dismissQueueVC() {
        self.dismissViewControllerAnimated(true, completion: nil)
        mainViewController = nil
    }
    
    /// Shows the Devices List
    ///
    func showDevices() {
        
        let popoverVC: UIViewController = (storyboard?.instantiateViewControllerWithIdentifier("DevicesViewController"))!
        
        popoverVC.modalTransitionStyle = .CrossDissolve
        popoverVC.view.backgroundColor = UIColor.clearColor()
        
        popoverVC.modalPresentationStyle = .OverCurrentContext
        
        let blurEffect: UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let beView: UIVisualEffectView = UIVisualEffectView(effect: blurEffect)
        beView.tag = 1
        beView.frame = self.view.bounds;
        beView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        popoverVC.view.frame = self.view.bounds
        popoverVC.view.insertSubview(beView, atIndex: 0)
        popoverVC.view.tag = 1
        // Present it before configuring it
        presentViewController(popoverVC, animated: true, completion: nil)
        
    }
    
    /// wifi reachability changed notification
    ///
    func reachabilityChanged(notification: NSNotification) {
        self.reachabilityForWifi = notification.object as? Reachability
        setupView()
    }
}
