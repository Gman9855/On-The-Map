//
//  TableViewController.swift
//  On The Map
//
//  Created by Gershy Lev on 5/21/15.
//  Copyright (c) 2015 Gershy Lev. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var students: [Student]!
    
    override func viewDidLoad() {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        students = appDelegate.students
        var pinButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "pinButtonTapped:")
        var refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshButtonTapped:")
        navigationItem.rightBarButtonItems = [refreshButton, pinButton]
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: Bar Button Action Methods
    
    func pinButtonTapped(sender: UIBarButtonItem) {
        
    }
    
    func refreshButtonTapped(sender: UIBarButtonItem) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        NetworkHandler().requestStudentInfo { (students) -> () in
            if students.count > 0 {
                self.students = students
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                })
            }
            
        }
    }
    
    @IBAction func logoutButtonTapped(sender: UIBarButtonItem) {
        FBSDKLoginManager().logOut()
        var loginVC = storyboard?.instantiateViewControllerWithIdentifier("loginVC") as! UIViewController
        presentViewController(loginVC, animated: true, completion: nil)
    }
    
    
    // MARK: TableView Delegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        let student = students[indexPath.row]
        cell.textLabel?.text = student.title
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = students[indexPath.row]
        UIApplication.sharedApplication().openURL(NSURL(string: student.subtitle)!)
    }
}
