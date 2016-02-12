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
        
        authorLabel.text = (article["author"] as! String)
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