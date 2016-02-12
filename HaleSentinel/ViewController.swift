//
//  ViewController.swift
//  HaleSentinel
//
//  Created by Jacob Kohn on 1/29/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import UIKit
import wpxmlrpc

class ViewController: UIViewController {
    @IBOutlet weak var sentinelButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sentinelButton.addTarget(self, action: "goToSentinel:", forControlEvents: .TouchUpInside)
        
    }
    
    
    
    
    func goToSentinel(sender: UIButton) {
        var url = NSURL()
        url = NSURL(string: "http://halesentinel.org/xmlrpc.php")!
        
        var request = NSMutableURLRequest()
        request = NSMutableURLRequest(URL: url)
        
        var session = NSURLSession.sharedSession()
        
        let encoder = WPXMLRPCEncoder(method: "wp.getPosts", andParameters: [0,"Jacob Kohn", "sentinel"])
        
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
                //print(data)
                
                var decoder = WPXMLRPCDecoder(data: data)
                
                if(decoder.isFault()) {
                    print("oopsies")
                } else {
                    for(var i=0; i<10; i++) {
                        //print((decoder.object()[i].valueForKey("post_title") as! String) + " " + (decoder.object()[i].valueForKey("post_status") as! String))
                        //print(decoder.object()[i].valueForKey("post_title") as! String)
                        //print(decoder.object()[i].valueForKey("post_thumbnail")!.valueForKey("link") as! String)
                        
                        
                        print(decoder.object()[i].valueForKey("post_title") as! String)
                        
                        if let val = decoder.object()[i]["post_thumbnail"]!!["link"] {
                            if let x = val {
                                print(x)
                            } else {
                                print("value is nil")
                            }
                        } else {
                            print("key is not present in dict")
                        }

                        
                        
                        //print(decoder.object()[i])
//                        if(decoder.object()[i].valueForKey("post_thumbnail")!.valueForKey("link") != nil) {
//                            
//                            
//                            print("PRESENT " + (decoder.object()[i]["post_thumbnail"]!!["link"] as! String))
//                            
//                        } else {
//                            print("no esta aqui")
//                        }
                        print(" ")
                        print(" ")
                        print(" ")
                        
                    }
                    //print(decoder.object())
                }
                
                
                
                
                
            }
        }
        task.resume()
    }



    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

