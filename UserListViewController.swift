//
//  UserListViewController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 10/26/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit

private let reuseIdentifier = "UserCollectionViewCell"

class UserListViewController: UICollectionViewController {
  
  convenience init() {
    self.init(nibName: "UserListViewController", bundle: nil)
  }
  
  let dataSource: UserDataSource = {
    let users = UserDataSource()
    users.loadUsersFromPlist(named: "Users")
    return users
  }()
  
  let colors: [UIColor] = [.redColor(), .greenColor(), .yellowColor(), .blueColor(),
    .orangeColor(), .redColor(), .greenColor(), .yellowColor()]

  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Users"
    
    view.backgroundColor = .whiteColor()
    edgesForExtendedLayout = .None
    
    collectionView!.registerNib(UINib(nibName: "UserCollectionViewCell", bundle: nil),
      forCellWithReuseIdentifier: reuseIdentifier)
    
    let layout = collectionView!.collectionViewLayout as! UserCollectionViewLayout
    layout.numberOfItemsInRow = 2
    layout.delegate = self
  }
  
  // MARK: UICollectionViewDataSource
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }

  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  override func collectionView(
    collectionView: UICollectionView,
    cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
        reuseIdentifier,
        forIndexPath: indexPath) as! UserCollectionViewCell
      
      cell.user = dataSource[indexPath.item]
      cell.backgroundColor = colors[indexPath.item]
      cell.delegate = self
    
      return cell
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    let layout = collectionView.collectionViewLayout as! UserCollectionViewLayout
    layout.animatingIndexPath = indexPath
    
    collectionView.performBatchUpdates({ () -> Void in
      layout.invalidateLayout()
      collectionView.setCollectionViewLayout(layout, animated: true)
    }, completion: nil)
  }
}

extension UserListViewController: UserCollectionViewLayoutDelegate {
  
  func collectionView(
    collectionView: UICollectionView,
    layout userCollectionViewLayout: UserCollectionViewLayout,
    heightForUserAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
      return 150.0
  }
}

extension UserListViewController: UserCollectionViewCellDelegate {

  func cell(cell: UserCollectionViewCell, detailButtonTapped button: UIButton) {
    if let indexPath = collectionView?.indexPathForCell(cell) {
      
      let userViewController = UserViewController()
      userViewController.user = dataSource[indexPath.item]

      self.navigationController?.pushViewController(userViewController, animated: true)
    }
  }
}