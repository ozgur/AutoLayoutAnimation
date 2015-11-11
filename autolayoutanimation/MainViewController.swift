//
//  MainViewController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 10/16/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit
import Cartography

class MainViewController: UITableViewController {
  
  let v: CGFloat = 5
  
  let refreshView: UIView = {
    let view = UIView(frame: CGRectZero)
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    view.addSubview(activityIndicatorView)
    
    activityIndicatorView.hidesWhenStopped = false

    constrain(activityIndicatorView, v2: view) { activityIndicatorView, view in
      activityIndicatorView.center == view.center
    }
    return view
  }()
  
  var titles = ["Extensions", "Layers", "Animation", "Alamofire", "Mapper", "UI Testing"]
  var copies = [
    [
      "Image Scaling"
    ],
    [
      "Scrollable Layers"
    ],
    [
      "Animating Height",
      "Animating Transform Matrix",
      "Core Animation"
    ],
    [
      "Basics",
      "Intermediate",
      "Streaming",
      "Pagination",
      "Parsing XML",
      "Object Serializer"
    ],
    [
      "Basics",
      "Nested Objects"
    ],
    [
      "Users"
    ]
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
        
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
    tableView.tableFooterView = UIView(frame: CGRectZero)
    tableView.addSubview(refreshView)
    
    tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
    
    constrain(tableView, v2: refreshView) { tableView, refreshView in
      refreshView.height == 80.0
      refreshView.width == tableView.width
      refreshView.centerX == tableView.centerX
      refreshView.top == tableView.top - 80.0
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated);
  }

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return copies.count
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return copies[section].count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier", forIndexPath: indexPath)

    cell.backgroundColor = UIColor.clearColor()
    cell.textLabel?.text = copies[indexPath.section][indexPath.row]

    return cell
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return titles[section]
  }

  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 35.0
  }
  
  // MARK: UITableViewDelegate methods

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    switch indexPath.section {
    case 0:
      switch indexPath.row {
      case 0:
        navigationController?.pushViewController(ImageViewController(), animated: true)
      default:
        break
      }
    case 1:
      switch indexPath.row {
      case 0:
        self.presentViewController(CAScrollViewController(), animated: true, completion: nil)
      default:
        break
      }
    case 2:
      switch indexPath.row {
      case 0:
        navigationController?.pushViewController(BoxViewController(nibName: "BoxViewController", bundle: nil), animated: true)
      case 1:
        navigationController?.pushViewController(TransformViewController(), animated: true)
      case 2:
        navigationController?.pushViewController(CoreAnimationViewController(), animated: true)
      default:
        break
      }
    case 34:
      switch indexPath.row {
      case 0:
        navigationController?.pushViewController(BasicObjectMapperViewController(), animated: true)
      case 1:
        navigationController?.pushViewController(NestedObjectMapperViewController(), animated: true)
      default:
        break
      }
    case 5:
      switch indexPath.row {
      case 0:
        navigationController?.pushViewController(UserListViewController(), animated: true)
      default:
        break
      }
    default:
      break
    }
  }
}
