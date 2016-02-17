//
//  HomeViewController.swift
//  HaleSentinel
//
//  Created by Jacob Kohn on 2/7/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit
import wpxmlrpc

class HomeViewController: UITableViewController, UINavigationBarDelegate {
    
    var articles = [NSDictionary]()
    var news = [NSDictionary]()
    var features = [NSDictionary]()
    var sports = [NSDictionary]()
    var opinion = [NSDictionary]()
    var ae = [NSDictionary]()
    var columns = [NSDictionary]()
    var weeklyRoundups = [NSDictionary]()
    var uncategorized = [NSDictionary]()
    var currentType = Int()
    
    let types = ["all", "news", "features", "sports", "opinion", "ae", "columns", "weekly-roundups", "uncategorized"]
    
    @IBOutlet weak var table: UITableView!
    
    func sortArticles() {
        news = [NSDictionary]()
        features = [NSDictionary]()
        sports = [NSDictionary]()
        opinion = [NSDictionary]()
        ae = [NSDictionary]()
        columns = [NSDictionary]()
        weeklyRoundups = [NSDictionary]()
        uncategorized = [NSDictionary]()
        
        for(var i=0; i<articles.count; i++) {

            for(var l=0; l<articles[i]["catagories"]!.count; l++) {

                if((articles[i]["catagories"]![l] as! String) == "news") {
                    news.append(articles[i])
                }
                if((articles[i]["catagories"]![l] as! String) == "features") {
                    features.append(articles[i])
                }
                if((articles[i]["catagories"]![l] as! String) == "sports") {
                    sports.append(articles[i])
                }
                if((articles[i]["catagories"]![l] as! String) == "opinion") {
                    opinion.append(articles[i])
                }
                if((articles[i]["catagories"]![l] as! String) == "ae") {
                    ae.append(articles[i])
                }
                if((articles[i]["catagories"]![l] as! String) == "columns") {
                    columns.append(articles[i])
                }
                if((articles[i]["catagories"]![l] as! String) == "weekly-roundups") {
                    weeklyRoundups.append(articles[i])
                }
                if((articles[i]["catagories"]![l] as! String) == "uncategorized") {
                    
                    uncategorized.append(articles[i])
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeCatagory:", name: "changeCatagory", object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "articlesPosted:", name: "postArticles", object: nil)
        currentType = 9
        
        table.dataSource = self
        table.delegate = self
        
        print("opened")
        
        sortArticles()
        configureNavBar()
    }
    
    func changeCatagory(notification: NSNotification) {
        let catagory = notification.object as! Int
        
        currentType = catagory
        
        table.reloadData()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func openMenu(sender: UIBarButtonItem) {
        NSNotificationCenter.defaultCenter().postNotificationName("toggleMenu", object: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        NSNotificationCenter.defaultCenter().postNotificationName("closeMenuViaNotification", object: nil)
        view.endEditing(true)
    }
    
    func openPushWindow(){
            performSegueWithIdentifier("openPushWindow", sender: nil)
    }

    
    func configureNavBar() {
        let blue = UIColor(red: 0.0, green: 0.0, blue: 0.509, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        let logo = UIImage(named: "h2.png")

        let menuImage = UIImage(named: "menuButtonSlim2.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: menuImage, style: .Plain, target: self, action: "openMenu:")
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.blackColor()
        
        let imageView = UIImageView(image:logo)
        
        self.navigationItem.titleView = imageView
        //self.navigationItem.titleView?.tintColor = UIColor.blackColor()
        
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.blackColor()
    }
    

    

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(currentType == 1) {
            return news.count
        } else if(currentType == 2) {
            return features.count
        } else if(currentType == 3) {
            return sports.count
        } else if(currentType == 4) {
            return opinion.count
        } else if(currentType == 5) {
            return ae.count
        } else if(currentType == 6) {
            return columns.count
        } else if(currentType == 7) {
            return weeklyRoundups.count
        } else if(currentType == 8) {
            return uncategorized.count
        } else {
            return articles.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("articleCell", forIndexPath: indexPath) as! ArticleCell
        
        var currentDictionary = NSDictionary()
        
        if(currentType == 1) {
            currentDictionary = news[indexPath.row]
        } else if(currentType == 2) {
            currentDictionary = features[indexPath.row]
        } else if(currentType == 3) {
            currentDictionary = sports[indexPath.row]
        } else if(currentType == 4) {
            currentDictionary = opinion[indexPath.row]
        } else if(currentType == 5) {
            currentDictionary = ae[indexPath.row]
        } else if(currentType == 6) {
            currentDictionary = columns[indexPath.row]
        } else if(currentType == 7) {
            currentDictionary = weeklyRoundups[indexPath.row]
        } else if(currentType == 8) {
            currentDictionary = uncategorized[indexPath.row]
        } else {
            currentDictionary = articles[indexPath.row]
        }
        
        cell.title.text = (currentDictionary.valueForKey("title") as! String)
        
        cell.preview.text = (currentDictionary.valueForKey("content") as! String)
        
        cell.preview.frame.size.width = self.view.frame.size.width - 51
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "readArticle") {
            if let indexPath = self.table.indexPathForSelectedRow {
                let controller = segue.destinationViewController as! ArticleViewController
                
                if(currentType == 1) {
                    controller.article = news[indexPath.row]
                } else if(currentType == 2) {
                    controller.article = features[indexPath.row]
                } else if(currentType == 3) {
                    controller.article = sports[indexPath.row]
                } else if(currentType == 4) {
                    controller.article = opinion[indexPath.row]
                } else if(currentType == 5) {
                    controller.article = ae[indexPath.row]
                } else if(currentType == 6) {
                    controller.article = columns[indexPath.row]
                } else if(currentType == 7) {
                    controller.article = weeklyRoundups[indexPath.row]
                } else if(currentType == 8) {
                    controller.article = uncategorized[indexPath.row]
                } else {
                    controller.article = articles[indexPath.row]
                }
            }
        }
    }
}
