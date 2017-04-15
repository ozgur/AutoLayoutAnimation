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
  
  fileprivate static let CellIdentifier = "UserCell"
  
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
    
    view.backgroundColor = .white
    edgesForExtendedLayout = UIRectEdge()
    
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: UserViewController.CellIdentifier)
    
    title = user.firstName
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    execute(delay: 2.0, repeating: false) {
      self.info = [self.user.fullName, String(self.user.userId), self.user.city]
    }
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return info.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: UserViewController.CellIdentifier)!
    
    cell.textLabel?.text = info[indexPath.row]
    cell.selectionStyle = .gray
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
