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
  
  let colors: [UIColor] = [.red, .green, .yellow, .blue,
    .orange, .red, .green, .yellow]

  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Users"
    
    view.backgroundColor = .white
    edgesForExtendedLayout = UIRectEdge()
    
    collectionView!.register(UINib(nibName: "UserCollectionViewCell", bundle: nil),
      forCellWithReuseIdentifier: reuseIdentifier)
    
    let layout = collectionView!.collectionViewLayout as! UserCollectionViewLayout
    layout.numberOfItemsInRow = 2
    layout.delegate = self
  }
  
  // MARK: UICollectionViewDataSource
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  override func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
      let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: reuseIdentifier,
        for: indexPath) as! UserCollectionViewCell
      
      cell.user = dataSource[indexPath.item]
      cell.backgroundColor = colors[indexPath.item]
      cell.delegate = self
    
      return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
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
    _ collectionView: UICollectionView,
    layout userCollectionViewLayout: UserCollectionViewLayout,
    heightForUserAtIndexPath indexPath: IndexPath) -> CGFloat {
    
      return 150.0
  }
}

extension UserListViewController: UserCollectionViewCellDelegate {

  func cell(_ cell: UserCollectionViewCell, detailButtonTapped button: UIButton) {
    if let indexPath = collectionView?.indexPath(for: cell) {
      
      let layout = collectionView?.collectionViewLayout as! UserCollectionViewLayout
      layout.animatingIndexPath = indexPath
      
      self.collectionView!.performBatchUpdates({ () -> Void in
        layout.invalidateLayout()
        self.collectionView!.setCollectionViewLayout(layout, animated: true)
        }, completion: nil)
    }
  }
}
