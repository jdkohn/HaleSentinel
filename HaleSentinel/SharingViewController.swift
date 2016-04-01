//
//  SharingViewController.swift
//  HaleSentinel
//
//  Created by Jacob Kohn on 3/30/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit
import Social
import MessageUI

class SharingViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var messaging: UIButton!
    //@IBOutlet weak var facebook: UIButton!
    @IBOutlet weak var twitter: UIButton!
    var link = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messaging.addTarget(self, action: "message:", forControlEvents: .TouchUpInside)
        //facebook.addTarget(self, action: "facebookShare:", forControlEvents: .TouchUpInside)
        twitter.addTarget(self, action: "tweet:", forControlEvents: .TouchUpInside)
        copyButton.addTarget(self, action: "copyToClipboard:", forControlEvents: .TouchUpInside)
        
    }
    
    func copyToClipboard(sender: UIButton) {
        UIPasteboard.generalPasteboard().string = link
    }
    
    func tweet(sender: UIButton) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterSheet.setInitialText(link + " ")
            self.presentViewController(twitterSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func facebookShare(sender: UIButton) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText(link + " ")
            self.presentViewController(facebookSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func message(sender: UIButton) {
        let messageVC = MFMessageComposeViewController()
        messageVC.body = link + " "
        messageVC.recipients = [] // Optionally add some tel numbers
        messageVC.messageComposeDelegate = self
        // Open the SMS View controller
        presentViewController(messageVC, animated: true, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch result.rawValue {
        case MessageComposeResultCancelled.rawValue :
            print("message canceled")
            
        case MessageComposeResultFailed.rawValue :
            print("message failed")
            
        case MessageComposeResultSent.rawValue :
            print("message sent")
            
        default:
            break
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}