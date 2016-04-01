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
import CoreData

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
    
    var timesLoggedIn = [NSManagedObject]()
    var users = [NSManagedObject]()
    
    var alert = UIAlertController()
    
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
        
        //Gets list of logs in
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName:"LogIn")
        let error: NSError?
        var fetchedResults = [NSManagedObject]()
        do {
            fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        timesLoggedIn = fetchedResults
        
        var lastLogIn = Double()
        
        //Sets time = to the last log in, later checked if > 60 days
        if(timesLoggedIn.isEmpty) {
            lastLogIn = NSDate().timeIntervalSince1970 - 100000000.0
        } else {
            lastLogIn = Double(timesLoggedIn[timesLoggedIn.count - 1].valueForKey("time") as! Int)
        }
        
        if((NSDate().timeIntervalSince1970 - lastLogIn) > 5184000.0) {
            
            alert = UIAlertController(title: "Give us one second", message: "Updating the author list", preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
            
            updateLogIn(lastLogIn)
            getUsers()
        }
    
    }
    
    func getUsers() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName:"User")
        let error: NSError?
        var fetchedResults = [NSManagedObject]()
        do {
            fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        users = fetchedResults
        
        
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDel.managedObjectContext
        let coord = appDel.persistentStoreCoordinator
        
        //let fetchRequest = NSFetchRequest(entityName: "User")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.executeRequest(deleteRequest, withContext: context)
        } catch let error as NSError {
            debugPrint(error)
        }
        
        var url = NSURL()
        url = NSURL(string: "http://halesentinel.org/xmlrpc.php")!
        
        var request = NSMutableURLRequest()
        request = NSMutableURLRequest(URL: url)
        
        var session = NSURLSession.sharedSession()
        
        let filter : [String:AnyObject] = [
            "number" : 1000,
        ]
        
        let encoder = WPXMLRPCEncoder(method: "wp.getUsers", andParameters: [0,"Jacob Kohn", "sentinel", filter])
        
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
                
                self.parseUsers(decoder.object() as! [NSDictionary])
                
                self.alert.dismissViewControllerAnimated(true, completion: nil)
                //self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
        task.resume()
    }
    
    
    /*
    * This method sorts the users
    * Paramater: decoder [NSDictionary] - the key-value array from
    * Wordpress that was returned from the XMLRPC API call
    */
    func parseUsers(decoder: [NSDictionary]) {
        //Loops through all Users returned from the function
        for(var i=0; i<decoder.count; i++) {
            let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            
            let entity =  NSEntityDescription.entityForName("User",
                inManagedObjectContext:
                managedContext)
            
            
            
            //Stores the user in Core Data
            let userObject = NSManagedObject(entity: entity!,
                insertIntoManagedObjectContext:managedContext)
            userObject.setValue(decoder[i]["display_name"] as! String, forKey: "name")
            userObject.setValue(Int(decoder[i]["user_id"] as! String), forKey: "id")
            
            var error: NSError?
            do {
                try managedContext.save()
            } catch var error1 as NSError {
                error = error1
                print("Could not save \(error), \(error?.userInfo)")
            }
            
            self.users.insert(userObject, atIndex: self.users.count)
            
            do {
                try managedContext.save()
            } catch _ {
            }
        }
    }
    
    /*
    * Updates the last time logged in, this is to update users, not to keep track of actual log-ins
    */
    func updateLogIn(lastLogIn: Double) {
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("LogIn",
            inManagedObjectContext:
            managedContext)
        
        //creates new log in object
        let logInObject = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        logInObject.setValue(Int(NSDate().timeIntervalSince1970), forKey: "time")
        
        var error: NSError?
        do {
            try managedContext.save()
        } catch var error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
        }
        
        self.timesLoggedIn.insert(logInObject, atIndex: self.timesLoggedIn.count)
        
        do {
            try managedContext.save()
        } catch _ {
        }
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
