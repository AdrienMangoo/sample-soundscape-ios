//
//  LibraryTableViewController.swift
//  SoundScape
//
//  Created by Prasath Thurgam on 5/12/15.
//  Copyright (c) 2015 samsung. All rights reserved.
//

import UIKit

class LibraryTableViewController: UITableViewController {

    var medias = NSMutableOrderedSet()
    var thumbnailImages = NSMutableOrderedSet()
    
    var userColor: String? = nil
    /// MultiScreenManager instance that manages the interaction with the services
    var multiScreenManager = MultiScreenManager.sharedInstance
    
    @IBAction func dismissLibrary(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        
        let session = NSURLSession(configuration: config)
        
        //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let url = NSURL(string: "http://s3-us-west-1.amazonaws.com/dev-multiscreen-music-library/library.json")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)) { [unowned self]  () -> Void in
            
            let dataTask = session.dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
                if (error == nil) {
                    
                    let httpResp = response as! NSHTTPURLResponse
                    if httpResp.statusCode == 200 {
                        
                        var serializationError: NSError?
                        let mediaData: [Dictionary] = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &serializationError) as! [[String:AnyObject]]
                        
                        if (serializationError == nil) {
                            let mediaInfos = mediaData.map {MediaItem(artist: $0["artist"] as! String, name: $0["album"] as! String, title: $0["title"] as! String, fileURL: $0["file"] as! String, albumArtURL: $0["albumArt"] as! String, thumbnailURL: $0["albumArtThumbnail"] as? String, id: self.generateTrackId(), duration: $0["duration"] as? Int, color:self.userColor)}
                            
                            
                            self.medias.addObjectsFromArray(mediaInfos)
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                self.tableView.reloadData()
                            })
                            
                        }
                    }
                }
            })
            
            dataTask.resume()
        }
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = self.userColor?.stringToColor()
        self.navigationController?.navigationBar.translucent = false
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont.systemFontOfSize(20)
        ]
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        if tableView.respondsToSelector("setSeparatorInset:") {
            tableView.separatorInset = UIEdgeInsetsZero
        }
        if tableView.respondsToSelector("setLayoutMargins:") {
            tableView.layoutMargins = UIEdgeInsetsZero
        }
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
        
        // Set tableView separator style
        tableView.separatorStyle  = UITableViewCellSeparatorStyle.SingleLine
        if cell.respondsToSelector("setSeparatorInset:") {
            cell.separatorInset = UIEdgeInsetsZero
        }
        if cell.respondsToSelector("setLayoutMargins:") {
            cell.layoutMargins = UIEdgeInsetsZero
        }
        cell.thumbnailImageView.image = UIImage(named: "album_placeholder")
        if let imageURLEncoded = imageURL!.URLEncodedString() {
            
//            Alamofire.request(.GET, imageURLEncoded).response() {
//                (_, _, data, _) in
//                
//                let image = UIImage(data: data! as! NSData)
//                cell.thumbnailImageView.image = image
//            }

//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)) { [unowned self]  () -> Void in
//                let url = NSURL(string: imageURLEncoded)
//                
//                let downloadPhotoTask: NSURLSessionDownloadTask = NSURLSession.sharedSession().downloadTaskWithURL(url!, completionHandler: { [unowned self] (location, response, error) -> Void in
//                    let downloadedImage = UIImage(data: NSData(contentsOfURL: location)!)
//                    dispatch_async(dispatch_get_main_queue(),{
//                        if let updateCell = tableView.cellForRowAtIndexPath(indexPath) as? MediaTableViewCell {
//                            updateCell.thumbnailImageView.image = downloadedImage
//                        }
//                        //cell.thumbnailImageView.image = downloadedImage
//                    })
//                    
//                    })
//                downloadPhotoTask.resume()
//            }
            
            let url = NSURL(string: imageURLEncoded)
            cell.thumbnailImageView.setImageWithUrl(url!, placeHolderImage: UIImage(named: "album_placeholder"))
            
            
        }
        return cell
    }
    
    
    // returns nil if cell is not visible or index path is out of range
    func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell?  {
        if let updateCell = tableView.cellForRowAtIndexPath(indexPath) as? MediaTableViewCell {
            //updateCell.thumbnailImageView.image = downloadedImage
            return updateCell
        }
        return nil
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var text: String = String("added to playlist")

        var hud = MBProgressHUD(view: self.view)
        let cgFloat: CGFloat = CGRectGetMinY(tableView.bounds);
        let someFloat: Float = Float(cgFloat)
        hud.yOffset = someFloat
        self.view.addSubview(hud)
        
        let toastMsg = (medias.objectAtIndex(indexPath.row) as! MediaItem).title! + String(" added to playlist")
        
        hud.labelText = toastMsg
        hud.show(true)
        hud.dimBackground = true
        
        
        generateTrackId()
        
        self.multiScreenManager.sendAddTrack(medias.objectAtIndex(indexPath.row) as! MediaItem)
        
        dispatch_async(dispatch_get_main_queue(), {
            // stop the hud
            hud.hide(true, afterDelay: 1)
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
