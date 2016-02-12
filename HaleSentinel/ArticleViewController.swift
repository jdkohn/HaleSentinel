//
//  ArticleViewController.swift
//  HaleSentinel
//
//  Created by Jacob Kohn on 2/9/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit

class ArticleViewController: UIViewController {
    
    var article = NSDictionary()
    
    let authors : [NSDictionary] = [["id": 108, "author": "Michael Foster"], ["id": 81, "author": "Henry Graham"], ["id": 79, "author": "Sylvie Corwin"], ["id": 59, "author": "Garrett Lawrence"], ["id": 61, "author": "Emma Johnson"], ["id": 83, "author": "Tucker Doyle"], ["id": 44, "author": "Jason Moore"], ["id": 97, "author": "Thea Watrous"], ["id": 100, "author": "Julia Berkey"], ["id": 40, "author": "Stella Ramos"], ["id": 13, "author": "Millie Jones"], ["id": 35, "author": "Elijah Falk"], ["id": 80, "author": "Jasmin Uxa"], ["id": 85, "author": "Dominic Davis"], ["id": 93, "author": "Dominic Danis"], ["id": 93, "author": "Luke Notkin"], ["id": 82, "author": "Mr. Vogue"], ["id": 84, "author": "Nathan Walsh"]]
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = article.valueForKey("title") as! String
        contentLabel.text = article.valueForKey("content") as! String
        
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
                constant: self.view.frame.size.width)
            self.view.addConstraint(imageWidth)
            
            let imageHeight = NSLayoutConstraint (item: imageView,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: nil,
                attribute: NSLayoutAttribute.NotAnAttribute,
                multiplier: 1,
                constant: self.view.frame.size.width / 2)
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
                self.imageView.image = self.image
            })
        })
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}