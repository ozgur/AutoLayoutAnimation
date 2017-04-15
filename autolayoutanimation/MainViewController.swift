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
    let view = UIView(frame: CGRect.zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
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
      "Scrollable Layers",
      "Replicator Layers"
    ],
    [
      "Animating Height",
      "Animating Transform Matrix",
      "Core Animation",
      "Custom Animation"
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
        
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    tableView.addSubview(refreshView)
    
    tableView.cellForRow(at: IndexPath(row: 1, section: 0))
    
    constrain(tableView, v2: refreshView) { tableView, refreshView in
      refreshView.height == 80.0
      refreshView.width == tableView.width
      refreshView.centerX == tableView.centerX
      refreshView.top == tableView.top - 80.0
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated);
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return copies.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return copies[section].count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)

    cell.backgroundColor = UIColor.clear
    cell.textLabel?.text = copies[indexPath.section][indexPath.row]

    return cell
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return titles[section]
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 35.0
  }
  
  // MARK: UITableViewDelegate methods

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
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
        self.present(CAScrollViewController(), animated: true, completion: nil)
      case 1:
        self.navigationController?.pushViewController(CAReplicatorViewController(), animated: true)
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
      case 3:
        navigationController?.pushViewController(
          PetsViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil),
          animated: true)
      default:
        break
      }
    case 3:
      switch indexPath.row {
      case 0:
        navigationController?.pushViewController(AlamofireViewController(), animated: true)
      case 1:
        navigationController?.pushViewController(AlamofirePostViewController(), animated: true)
      case 2:
        navigationController?.pushViewController(AlamofireDownloadViewController(), animated: true)
      case 3:
        navigationController?.pushViewController(AlamofirePaginationViewController(), animated: true)
      case 4:
        navigationController?.pushViewController(AlamofireXMLViewController(), animated: true)
      case 5:
        navigationController?.pushViewController(AlamofireSerializeViewController(), animated: true)
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
