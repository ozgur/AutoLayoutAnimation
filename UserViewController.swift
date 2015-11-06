//
//  UserViewController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 10/27/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit

class UserViewController: UITableViewController {
  
  var user: User!
  
  private static let CellIdentifier = "UserCell"
  
  var info = [String]() {
    didSet {
      tableView.reloadData()
    }
  }
  
  convenience init() {
    self.init(nibName: "UserViewController", bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .whiteColor()
    edgesForExtendedLayout = .None
    
    tableView.tableFooterView = UIView(frame: CGRectZero)
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: UserViewController.CellIdentifier)
    
    title = user.firstName
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    execute(delay: 2.0, repeating: false) {
      self.info = [self.user.fullName, String(self.user.userId), self.user.city]
    }
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return info.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(UserViewController.CellIdentifier)!
    
    cell.textLabel?.text = info[indexPath.row]
    cell.selectionStyle = .Gray
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}
