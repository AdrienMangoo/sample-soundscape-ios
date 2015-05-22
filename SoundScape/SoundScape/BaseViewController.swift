//
//  BaseViewController.swift
//  SoundScape
//
//  Created by Prasath Thurgam on 5/13/15.
//  Copyright (c) 2015 samsung. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /// MultiScreenManager instance that manages the interaction with the services
    var multiScreenManager = MultiScreenManager.sharedInstance
    
    /// UIView that contains a list of available services
    var servicesView: ServicesView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add an observer to check for services status and manage the cast icon
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "setCastIcon", name: multiScreenManager.servicesChangedObserverIdentifier, object: nil)
        //configure the Cast icon and Settings icon
        //setCastIcon()
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Remove observer
        //NSNotificationCenter.defaultCenter().removeObserver(self, name: multiScreenManager.servicesChangedObserverIdentifier, object: nil)
    }
    
    /// Shows a list of available services
    /// User can connect to a service
    /// User can disconnect from a connected service
    func showCastMenuView(){
        
        /// UIView that contains a list of available services
        var viewArray = NSBundle.mainBundle().loadNibNamed("ServicesView", owner: self, options: nil)
        servicesView = viewArray[0] as! ServicesView
        servicesView.frame = UIScreen.mainScreen().bounds
        
        /// Adding UIVIew to superView
        addUIViewToWindowSuperView(servicesView)
    }
    
    func addUIViewToWindowSuperView(view: UIView){
        
        /// Adding UIVIew to superView
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var window = UIApplication.sharedApplication().keyWindow
        if (window == nil){
            window = UIApplication.sharedApplication().windows[0] as? UIWindow
        }
        
        window?.subviews[0].addSubview(view)
        
        /// Adding view constraints
        let viewDict = ["view": view]
        window?.subviews[0].addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewDict))
        window?.subviews[0].addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewDict))
        
    }

}
