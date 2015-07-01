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
        let url = NSURL(string: "http://multiscreen.samsung.com/examples/soundscape/music/library.json")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)) { [unowned self]  () -> Void in
            
            let dataTask = session.dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
                if (error == nil) {
                    
                    let httpResp = response as! NSHTTPURLResponse
                    if httpResp.statusCode == 200 {
                        
                        var serializationError: NSError?
                        let mediaData: [Dictionary] = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &serializationError) as! [[String:AnyObject]]
                        
                        if (serializationError == nil) {
                            let mediaInfos = mediaData.map {MediaItem(artist: $0["artist"] as! String, name: $0["album"] as! String, title: $0["title"] as! String, fileURL: $0["file"] as! String, albumArtURL: $0["albumArt"] as! String, thumbnailURL: ($0["albumArtThumbnail"] as? String)!, id: self.generateTrackId(), duration: ($0["duration"] as? Int)!, color:self.userColor!)}
                            
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
        cell.artistLabel.text = (medias.objectAtIndex(indexPath.row) as! MediaItem).artist
        
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
            
            let url = NSURL(string: imageURLEncoded)
            cell.thumbnailImageView.setImageWithUrl(url!, placeHolderImage: UIImage(named: "album_placeholder"))
            
            
        }
        return cell
    }
    
    
    // returns nil if cell is not visible or index path is out of range
    func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell?  {
        if let updateCell = tableView.cellForRowAtIndexPath(indexPath) as? MediaTableViewCell {
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
