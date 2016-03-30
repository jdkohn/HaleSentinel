//
//  SplashScreen.swift
//  HaleSentinel
//
//  Created by Jacob Kohn on 2/10/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit
import wpxmlrpc

class SplashScreen: UIViewController {
    
    var articles = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadArticles()
    }
    
    func loadArticles() {
        if(Reachability.isConnectedToNetwork()) {
            getArticles()
        } else {
            let alert = UIAlertController(title: "Oops!", message: "You are not connected to the Internet", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { (action) -> Void in
                self.loadArticles()
            }))
            
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }
    
    func getArticles() {
        var url = NSURL()
        url = NSURL(string: "http://halesentinel.org/xmlrpc.php")!
        
        var request = NSMutableURLRequest()
        request = NSMutableURLRequest(URL: url)
        
        var session = NSURLSession.sharedSession()
        
        let filter : [String:AnyObject] = [
            "number" : 50,
            "post_status" : "publish"
        ]
        
        let encoder = WPXMLRPCEncoder(method: "wp.getPosts", andParameters: [0,"Jacob Kohn", "sentinel", filter])
        
        do {
            request.HTTPBody = try encoder.dataEncoded()
            request.HTTPMethod = "POST"
        } catch _ {
            print("oops")
        }
        
        var task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            if error != nil {
                print("callback fail")
                print(error)
            } else {
                
                let decoder = WPXMLRPCDecoder(data: data)
                
                if(decoder.isFault()) {
                    print("oopsies")
                } else {
                    
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                print("recieved")
                
                let decoder = WPXMLRPCDecoder(data: data)
                
                self.parseDecoder(decoder.object() as! [NSDictionary])
            })
        }
        task.resume()
    }
    
    func parseDecoder(decoder: [NSDictionary]) {
        
        // GET FIELDS
        
        var temp = [NSDictionary]()
        for(var i=0; i<decoder.count; i++) {
            let name = decoder[i]["post_title"] as! String
            var content = decoder[i]["post_content"] as! String
            let id = decoder[i]["post_id"] as! String
            let author = decoder[i]["post_author"] as! String
            let link = decoder[i]["link"] as! String
            
            var catagories = [String]()
            if(decoder[i]["terms"]!.count != 0) {
                for(var l=0; l<decoder[i]["terms"]!.count; l++) {
                    catagories.append(decoder[i]["terms"]![l]!["slug"] as! String)
                }
            }
            let status = decoder[i]["post_status"] as! String
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
            //dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
            let date = dateFormatter.stringFromDate(decoder[i]["post_date"] as! NSDate)
            
            var imageLink = String()
            var image = Bool()
            if let val = decoder[i]["post_thumbnail"]!["link"] {
                if let x = val {
                    imageLink = x as! String
                    image = true
                } else {
                    image = false
                    imageLink = ""
                }
            } else {
                image = false
                imageLink = ""
            }
            
            
            // Parse Content
            if let range = content.rangeOfString("\n\n") {
                
                let intIndex: Int = content.startIndex.distanceTo(range.startIndex)
                let startIndex2 = content.startIndex.advancedBy(intIndex + 2)
                
                let substring = content.substringWithRange(Range<String.Index>(start: startIndex2, end: content.endIndex))
                content = substring
            }
            
            if let range = content.rangeOfString("[/caption]") {
                let intIndex: Int = content.startIndex.distanceTo(range.endIndex)
                let startIndex2 = content.startIndex.advancedBy(intIndex + 2)
                
                let substring = content.substringWithRange(Range<String.Index>(start: startIndex2, end: content.endIndex))
                content = substring
                
            }
            
            if let range = content.rangeOfString("p>\n") {
                let intIndex: Int = content.startIndex.distanceTo(range.endIndex)
                let startIndex2 = content.startIndex.advancedBy(intIndex - 1)
                
                let substring = content.substringWithRange(Range<String.Index>(start: startIndex2, end: content.endIndex))
                content = substring
            }
            
            content = content.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
            
            content = content.stringByReplacingOccurrencesOfString("&nbsp;", withString: "", options: .RegularExpressionSearch, range: nil)

            
            
            
            if(content == "[supsystic-gallery id=1 position=center]") {
                print("stupid content")
            }
            
            while(content.substringWithRange(Range<String.Index>(start: content.startIndex, end: content.startIndex.advancedBy(1))) == "\n") {
                
                content = content.substringWithRange(Range<String.Index>(start: content.startIndex.advancedBy(1), end: content.endIndex))
            }

            
            let pd = ["title": name, "content": content, "id": id, "author": author, "catagories": catagories, "status": status, "imageLink": imageLink, "image": image, "date": date, "link": link]
            
            if(name != "" && content != "[supsystic-gallery id=1 position=center]") {
                temp.append(pd)
            }
        }
        articles = temp
        performSegueWithIdentifier("doneLoading", sender: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "doneLoading") {
            let controller = segue.destinationViewController as! ContainerVC
            controller.articles = self.articles
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}