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
    var appDelegate: AppDelegate {
        let object = UIApplication.sharedApplication().delegate
        return object as! AppDelegate
    }
    lazy var networkHandler = NetworkHandler()
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addPostedStudentLocationToTableView:", name: "didPostStudentLocationNotification", object: nil)
        var refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshButtonTapped:")
        navigationItem.rightBarButtonItem = refreshButton
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: Bar Button Action Methods
    
    func refreshButtonTapped(sender: UIBarButtonItem) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        networkHandler.requestStudents { (students) -> () in
            if students.count > 0 {
                self.appDelegate.students = students
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
        return appDelegate.students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        let student = appDelegate.students[indexPath.row]
        cell.textLabel?.text = student.fullName
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = appDelegate.students[indexPath.row]
        if let mediaURL = student.mediaURL {
            UIApplication.sharedApplication().openURL(student.mediaURL!)
        }
    }
}
