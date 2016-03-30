//
//  ArticleViewController.swift
//  HaleSentinel
//
//  Created by Jacob Kohn on 2/9/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit
import Social

class ArticleViewController: UIViewController, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate {
    
    var article = NSDictionary()
    
    let authors : [NSDictionary] = [["id": 108, "author": "Michael Foster"], ["id": 81, "author": "Henry Graham"], ["id": 79, "author": "Sylvie Corwin"], ["id": 59, "author": "Garrett Lawrence"], ["id": 61, "author": "Emma Johnson"], ["id": 83, "author": "Tucker Doyle"], ["id": 44, "author": "Jason Moore"], ["id": 97, "author": "Thea Watrous"], ["id": 100, "author": "Julia Berkey"], ["id": 40, "author": "Stella Ramos"], ["id": 13, "author": "Millie Jones"], ["id": 35, "author": "Elijah Falk"], ["id": 80, "author": "Jasmin Uxa"], ["id": 85, "author": "Dominic Davis"], ["id": 93, "author": "Dominic Danis"], ["id": 93, "author": "Luke Notkin"], ["id": 82, "author": "Mr. Vogue"], ["id": 84, "author": "Nathan Walsh"]]
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var image = UIImage()
    
    var imageHeight = NSLayoutConstraint()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let container = self.parentViewController?.parentViewController as! ContainerVC
        container.scrollView.scrollEnabled = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "share:")
        
        popoverPresentationController?.delegate = self
        
        self.navigationController!.navigationBar.tintColor = UIColor.blackColor()
        
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.blackColor()
        
        titleLabel.text = (article.valueForKey("title") as! String)
        contentLabel.text = (article.valueForKey("content") as! String)
        
        let widthConstraint = NSLayoutConstraint (item: contentLabel,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: self.view.frame.size.width - 16)
        self.view.addConstraint(widthConstraint)
        
        let titleWidth = NSLayoutConstraint (item: titleLabel,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: self.view.frame.size.width - 16)
        self.view.addConstraint(titleWidth)
        
        

        let imageWidth = NSLayoutConstraint (item: imageView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: self.view.frame.size.width + 4)
        self.view.addConstraint(imageWidth)
        
        imageHeight = NSLayoutConstraint (item: imageView,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: 0)
        self.view.addConstraint(imageHeight)
        
        contentLabel.sizeToFit()
        
        scrollView.scrollEnabled = true
        
        var labelSet = false
        for(var i=0; i<authors.count; i++) {
            if(String(authors[i]["id"] as! Int) == (article["author"] as! String)) {
                authorLabel.text = "By: " + (authors[i]["author"] as! String)
                labelSet = true
                break;
            }
        }
        if(!labelSet) {
            authorLabel.text = ""
        }
        dateLabel.text = (article["date"] as! String)
        
        
        configureNavBar()
    }
    
    func share(sender: UIBarButtonItem) {
        
        performSegueWithIdentifier("share", sender: nil)

        
//        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
//            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
//            twitterSheet.setInitialText((self.article["link"] as! String))
//            self.presentViewController(twitterSheet, animated: true, completion: nil)
//        } else {
//            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
//        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x>0 {
            scrollView.contentOffset.x = 0
        }
        
        if scrollView.contentOffset.x<0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let container = self.parentViewController?.parentViewController as! ContainerVC
        container.scrollView.scrollEnabled = true
    }
    

    
    func configureNavBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        let logo = UIImage(named: "topLogo.png")
        
        let imageView = UIImageView(image:logo)
        
        self.navigationItem.titleView = imageView
        
    }
    
    func goHome(sender: UIScreenEdgePanGestureRecognizer) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            if(self.article["image"] as! Bool) {
                if let url = NSURL(string: self.article["imageLink"] as! String) {
                    if let data = NSData(contentsOfURL: url) {
                            self.image = UIImage(data: data)!
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if(self.image.size.width != 0) {
                    print("Changed Image Size")
                    
                    let multiplier = self.view.frame.size.width / self.image.size.width
                    
                    let height = self.image.size.height * multiplier
                    
                    let updatedHeight = NSLayoutConstraint (item: self.imageView,
                        attribute: NSLayoutAttribute.Height,
                        relatedBy: NSLayoutRelation.Equal,
                        toItem: nil,
                        attribute: NSLayoutAttribute.NotAnAttribute,
                        multiplier: 1,
                        constant: height)
                    self.view.addConstraint(updatedHeight)
                    self.view.removeConstraint(self.imageHeight)
                    self.imageView.image = self.image
                }
            })
        })
    }
    
    func home(sender: UIBarButtonItem) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "share" {
            let popoverViewController = segue.destinationViewController as! SharingViewController
            popoverViewController.link = article["link"] as! String
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
        }
    }
}