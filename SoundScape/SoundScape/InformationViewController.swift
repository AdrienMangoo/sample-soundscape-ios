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

class InformationViewController: UIViewController {
    
    @IBOutlet weak var informationWebView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let localfilePath = NSBundle.mainBundle().URLForResource("Information", withExtension: "html");
        let html = try? NSString(contentsOfURL: localfilePath!, encoding: NSUTF8StringEncoding)
    
        let ssid: String? = String(SSIdInfo.currentWifiSSID())
        var ssidDisplay: String = String()
        
        if ssid != nil {
            ssidDisplay = ssid!
        } else {
            ssidDisplay = "your network"
        }
        
        let htmlString = html?.stringByReplacingOccurrencesOfString("%%SSID%%", withString: ssidDisplay) as String?
        informationWebView.loadHTMLString(htmlString!, baseURL: nil)
    }

    @IBAction func dismissInformationVC(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
