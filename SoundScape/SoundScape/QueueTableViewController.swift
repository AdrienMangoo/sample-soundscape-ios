//
//  QueueTableViewController.swift
//  SoundScape
//
//  Created by Prasath Thurgam on 5/12/15.
//  Copyright (c) 2015 samsung. All rights reserved.
//

import UIKit

class QueueTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate {

    var queueMedias = NSMutableOrderedSet()
    
    /// MultiScreenManager instance that manages the interaction with the services
    var multiScreenManager = MultiScreenManager.sharedInstance
    
    var currentTrackId = String()
    var currentTrackState = String("unknown")
    
    var userColor = String()
    
    var disconnectPopoverController: UIPopoverController? = nil
    /// UITableView to diplay the services
    @IBOutlet weak var queueTableView: UITableView!
    
    @IBOutlet weak var userColorImageView: UIImageView!
    
    @IBOutlet weak var connectedDeviceImageView: UIImageView!
    
    @IBOutlet weak var connectedDeviceLabel: UILabel!
    
    @IBOutlet weak var mediaActionToolbar: UIToolbar!
    
    @IBOutlet weak var playPauseBarButton: UIBarButtonItem!
    
    @IBOutlet weak var nextTrackBarButton: UIBarButtonItem!
    
    @IBOutlet weak var currentTrackTitleLabel: UILabel!
    
    @IBOutlet weak var currentTrackNameLabel: UILabel!
    
    @IBAction func castButtonPressed(sender: AnyObject) {
        
        showDisconnectPopover(sender)
    }
    
    @IBAction func addButonPressed(sender: AnyObject) {
    }
    
    @IBAction func testButtonPressed(sender: AnyObject) {
        
        //multiScreenManager.sendAppStateRequest()
        multiScreenManager.sendPlayPause(true)
    }
    
    @IBAction func nextTrackButtonPressed(sender: AnyObject) {
        multiScreenManager.sendNextTrack()
        
        if self.queueMedias.count > 0 {
            self.queueMedias.removeObjectAtIndex(0)
            self.queueTableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        let homeVC = UIApplication.sharedApplication().keyWindow?.rootViewController as! HomeViewController
        
        
        // Add an observer to check if a tv is connected
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serviceSelected", name: multiScreenManager.serviceSelectedObserverIdentifier, object: nil)
        
        // Add an observer to check for services status and manage the cast icon
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshQueue:", name: multiScreenManager.refreshQueueObserverIdentifier, object: nil)
        
        
        // Add an observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCurrentStatus:", name: multiScreenManager.currentTrackStatusObserverIdentifier, object: nil)
        
        // Add an observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addTrack:", name: multiScreenManager.addTrackObserverIdentifier, object: nil)
        
        if queueTableView.respondsToSelector("setSeparatorInset:") {
            queueTableView.separatorInset = UIEdgeInsetsZero
        }
        if queueTableView.respondsToSelector("setLayoutMargins:") {
            queueTableView.layoutMargins = UIEdgeInsetsZero
        }
        
        self.queueTableView.allowsMultipleSelectionDuringEditing = false
        self.queueTableView.tableFooterView = UIView(frame: CGRectZero)
        //self.queueTableView.tableHeaderView = UIView(frame: CGRectZero)
        setupView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        println("$$$$$$$ QueueTableViewController - deinit")
        /*
        NSNotificationCenter.defaultCenter().removeObserver(self, name: multiScreenManager.serviceSelectedObserverIdentifier, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: multiScreenManager.refreshQueueObserverIdentifier, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: multiScreenManager.currentTrackStatusObserverIdentifier, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: multiScreenManager.addTrackObserverIdentifier, object: nil)
        */
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return queueMedias.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("QueueMediaTableViewCellID", forIndexPath: indexPath) as! QueueMediaTableViewCell
        
        // Configure the cell...
        
        cell.titleLabel.text = (queueMedias[indexPath.row] as! MediaItem).title
        cell.albumNameLabel.text = (queueMedias[indexPath.row] as! MediaItem).name
        
        var imageURL: String? = (queueMedias.objectAtIndex(indexPath.row) as! MediaItem).thumbnailURL
        
        let userColor = (queueMedias[indexPath.row] as! MediaItem).color
        if let imageURLEncoded = imageURL!.URLEncodedString() {
            let url = NSURL(string: imageURLEncoded)
            cell.thumbnailImageView.setImageWithUrl(url!, placeHolderImage: UIImage(named: "album_placeholder"))
        }
        cell.userColorImageView.image = UIImage.imageWithStringColor(userColor!)
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            multiScreenManager.sendRemoveTrack(queueMedias.objectAtIndex(indexPath.row) as! MediaItem)
            queueMedias.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }

    func refreshQueue(notification: NSNotification) {
        //println(notification)
        let userInfo: [String:AnyObject] = notification.userInfo as! [String:AnyObject]
        let queueMediaInfos = userInfo["userInfo"] as! [MediaItem]
        
        self.queueMedias.removeAllObjects()
        self.queueMedias.addObjectsFromArray(queueMediaInfos)
        
        self.queueTableView.reloadData()
        
        if (self.queueMedias.count > 0) {
            mediaActionToolbar.hidden = false
        } else {
            mediaActionToolbar.hidden = true
        }
    }
    
    func addTrack(notification: NSNotification) {
        //println(notification)
        let userInfo: [String:AnyObject] = notification.userInfo as! [String:AnyObject]
        let queueMediaInfos = userInfo["userInfo"] as! [MediaItem]
        
        self.queueMedias.addObjectsFromArray(queueMediaInfos)
        
        self.queueTableView.reloadData()
        
        if (self.queueMedias.count > 0) {
            mediaActionToolbar.hidden = false
        } else {
            mediaActionToolbar.hidden = true
        }
    }
    
    func playPause() {
        if self.currentTrackState == "playing" {
            multiScreenManager.sendPlayPause(false)
        } else if self.currentTrackState == "paused" {
            multiScreenManager.sendPlayPause(true)
        } else {
            multiScreenManager.sendPlayPause(true)
        }
    }
    
    
    func updateCurrentStatus(notification: NSNotification) {
        println(notification)
        let userInfo: [String:AnyObject] = notification.userInfo as! [String:AnyObject]
        if let currentStatusDict = (userInfo["userInfo"] as? [String:AnyObject]) {
            self.currentTrackId = currentStatusDict["id"] as! String
            self.currentTrackState = currentStatusDict["state"] as! String
            
            setupToolbar()
            //self.queueTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            
        }
    }
    
    func setupToolbar() {
        
        for elem in self.queueMedias {
            let queueMediaItem  = elem as! MediaItem
            if (queueMediaItem.id == currentTrackId) {
                self.currentTrackTitleLabel.text = queueMediaItem.title
                self.currentTrackNameLabel.text = queueMediaItem.name
                break
            }
        }
        var button: UIBarButtonItem = UIBarButtonItem()
        if self.currentTrackState == "playing" {
            button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Pause, target: self, action: "playPause")
        } else if self.currentTrackState == "paused" {
            button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Play, target: self, action: "playPause")
        }
        button.tintColor = UIColor.whiteColor()
        
        var toolbarItems: [AnyObject]? = mediaActionToolbar.items
        
        
        toolbarItems?[0] = button
        mediaActionToolbar.items = toolbarItems
        
    }
    func serviceSelected() {
        //setupView()
    }
    
    func chooseUserColor() -> String{
        let colors = ["#EF6C00","#1A237E","#689F38","#E91E63","#2196F3","#B71C1C","#01579B","#009688","#673AB7","#607D8B","#880E4F","#3F51B5","#827717","#9C27B0","#3E2723","#E65100","#006064","#1B5E20","#4A148C","#795548"]
        let colorIndex = Int(arc4random_uniform(20))
        
        let userColor: String = colors[colorIndex]
        return userColor
    }
    
    func setupView() {
        
        connectedDeviceLabel.text = multiScreenManager.currentService.displayName
        connectedDeviceImageView.image = multiScreenManager.isSpeaker(multiScreenManager.app.service) ? UIImage(named: "ic_speaker")! : UIImage(named: "ic_tv")!
        
        self.userColor = chooseUserColor()
        let colorString = self.userColor
        
        userColorImageView.image = UIImage.imageWithStringColor(colorString)
        
        multiScreenManager.sendAppStateRequest()
        
        //mediaActionToolbar.hidden = true
        
        var button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Pause, target: self, action: "playPause")
        button.tintColor = UIColor.whiteColor()
        
        var toolbarItems: [AnyObject]? = mediaActionToolbar.items
        
        
        toolbarItems?[0] = button
        mediaActionToolbar.items = toolbarItems
        
        currentTrackNameLabel.text = "name"
        currentTrackTitleLabel.text = "title"
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LibraryNavigationVC" {
            let libraryNaviVC = segue.destinationViewController as! UINavigationController
            let libraryVC = libraryNaviVC.viewControllers[0] as! LibraryTableViewController
            libraryVC.userColor = self.userColor
        }
    }
    
    func showDisconnectPopover(sender: AnyObject) {
        /*
        let disconnectVC = self.storyboard?.instantiateViewControllerWithIdentifier("DeviceDisconnectViewController") as? UIViewController
        
        disconnectPopoverController = UIPopoverController(contentViewController: disconnectVC!)
        disconnectPopoverController?.popoverContentSize = CGSize(width: 100, height: 100)
        disconnectPopoverController?.presentPopoverFromRect((sender as! UIButton).frame, inView: self.view, permittedArrowDirections: .Any, animated: true)
        */
        
        let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("DeviceDisconnectViewController") as! DeviceDisconnectViewController
        //popoverVC.modalPresentationStyle = .Popover
        popoverVC.userColor = self.userColor
        popoverVC.modalTransitionStyle = .CrossDissolve
        popoverVC.view.backgroundColor = UIColor.clearColor()
        
        popoverVC.modalPresentationStyle = .OverCurrentContext
        
        let blurEffect: UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
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
