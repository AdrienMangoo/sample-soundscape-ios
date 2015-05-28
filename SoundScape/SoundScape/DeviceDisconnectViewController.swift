//
//  DeviceDisconnectViewController.swift
//  SoundScape
//
//  Created by Prasath Thurgam on 5/26/15.
//  Copyright (c) 2015 samsung. All rights reserved.
//

import UIKit

class DeviceDisconnectViewController: UIViewController, UIGestureRecognizerDelegate {

    /// MultiScreenManager instance that manage the interaction with the services
    var multiScreenManager = MultiScreenManager.sharedInstance
    var userColor: String? = nil
    
    @IBOutlet weak var containerView: UIView!
    
    
    @IBOutlet weak var connectedDeviceImageView: UIImageView!
    
    @IBOutlet weak var connectedDeviceLabel: UILabel!
    
    @IBOutlet weak var disconnectButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        containerView.layer.masksToBounds = true
        containerView.layer.shadowColor = UIColor.blackColor().CGColor
        containerView.layer.shadowOpacity = 0.6
        containerView.layer.shadowRadius = 2.0
        containerView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        //containerView.layer.borderWidth = 0.1
        //containerView.layer.borderColor = UIColor.blackColor().CGColor

        /// Add a gesture recognizer to dismiss the current view on tap
        let tap = UITapGestureRecognizer()
        tap.delegate = self
        tap.addTarget(self, action: "closeView")
        self.view.addGestureRecognizer(tap)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(animated: Bool) {
        if multiScreenManager.app != nil {
            connectedDeviceLabel?.text = "\(multiScreenManager.app.service.name)"
        }
        connectedDeviceImageView.image = multiScreenManager.isSpeaker(multiScreenManager.app.service) ? UIImage(named: "ic_speaker_gray")! : UIImage(named: "ic_tv_gray")!
        
        disconnectButton.tintColor = self.userColor?.stringToColor()
    }
    
    @IBAction
    func disconnect() {
        multiScreenManager.app.disconnect()
        //self.dismissViewControllerAnimated(true) { }
        
    }

    /// UIGestureRecognizerDelegate used to disable the tap event if the tapped View is not the main View
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool{
        println(touch.view.tag)
        if (touch.view.tag == 1){
            return true
        }
        return false
    }
    
    /// Close the current View
    func closeView() {
        if (multiScreenManager.isConnected){
            //multiScreenManager.stopSearching()
        }
        
        //self.removeFromSuperview()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
