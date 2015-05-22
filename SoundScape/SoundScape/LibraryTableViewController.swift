//
//  LibraryTableViewController.swift
//  SoundScape
//
//  Created by Prasath Thurgam on 5/12/15.
//  Copyright (c) 2015 samsung. All rights reserved.
//

import UIKit
import Alamofire

class LibraryTableViewController: UITableViewController {

    var medias = NSMutableOrderedSet()
    
    var userColor: String? = nil
    /// MultiScreenManager instance that manages the interaction with the services
    var multiScreenManager = MultiScreenManager.sharedInstance
    
    @IBAction func dismissLibrary(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        Alamofire.request(.GET, "http://s3-us-west-1.amazonaws.com/dev-multiscreen-music-library/library.json").responseJSON() {
            (_, _, data, _) in
            println(data)
            let mediaInfos = (data as! [NSDictionary]).map {MediaItem(artist: $0["artist"] as! String, name: $0["album"] as! String, title: $0["title"] as! String, fileURL: $0["file"] as! String, albumArtURL: $0["albumArt"] as! String, thumbnailURL: $0["albumArtThumbnail"] as? String, id: self.generateTrackId(), duration: $0["duration"] as? Int, color:self.userColor)}
            println(mediaInfos)
            
            self.medias.addObjectsFromArray(mediaInfos)
            println(self.medias)
            
            self.tableView.reloadData()
            
            //let photoInfos = ((data as! NSDictionary).valueForKey("photos") as! [NSDictionary])
        }
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = self.userColor?.stringToColor()
        self.navigationController?.navigationBar.translucent = false
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont.systemFontOfSize(20)
        ]
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return medias.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MediaTableViewCellID", forIndexPath: indexPath) as! MediaTableViewCell
        
        // Configure the cell...
        
        
        var imageURL: String? = (medias.objectAtIndex(indexPath.row) as! MediaItem).thumbnailURL
        
        cell.titleLabel.text = (medias.objectAtIndex(indexPath.row) as! MediaItem).title
        cell.albumNameLabel.text = (medias.objectAtIndex(indexPath.row) as! MediaItem).name
        
        if let imageURLEncoded = imageURL!.URLEncodedString() {
            Alamofire.request(.GET, imageURLEncoded).response() {
                (_, _, data, _) in
                
                let image = UIImage(data: data! as! NSData)
                cell.thumbnailImageView.image = image
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var text: String = String("Added to Queue")
        // setup HUD; https://github.com/jdg/MBProgressHUD
        var hud2 = MBProgressHUD(view: self.view)
        let cgFloat: CGFloat = CGRectGetMinY(tableView.bounds);
        let someFloat: Float = Float(cgFloat)
        hud2.yOffset = someFloat
        self.view.addSubview(hud2)
        //hud2.center = self.view.center
        hud2.labelText = text
        hud2.show(true)
        
        //var hud = MBProgressHUD.showHUDAddedTo(tableView, animated: true)
        
        //hud.labelText = text
        
        generateTrackId()
        
        self.multiScreenManager.sendAddTrack(medias.objectAtIndex(indexPath.row) as! MediaItem)
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), {
            // Do something...
            //NSNotificationCenter.defaultCenter().postNotificationName(multiscreenManager.refreshQueueObserverIdentifier, object: self)
            
            dispatch_async(dispatch_get_main_queue(), {
                // stop the hud
                hud2.hide(true)
                //hud2.removeFromSuperview()
                //MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Or just call hud.hide(true)
                });
            });
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    func generateTrackId() -> String {
        var k: Int = randomInt(1000000, max: 99999999)
        var s = String(k)
        println(s)
        return s
    }

}
