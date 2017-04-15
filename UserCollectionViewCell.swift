//
//  UserCollectionViewCell.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 10/26/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit

@objc
protocol UserCollectionViewCellDelegate: class {
  optional func cell(_ cell: UserCollectionViewCell, detailButtonTapped button: UIButton)
}

class UserCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet fileprivate weak var nameLabel: UILabel!
  @IBOutlet fileprivate weak var someLabel: UILabel!
  
  weak var delegate: UserCollectionViewCellDelegate!
  
  var height: CGFloat = 0

  var user: User! {
    didSet {
      nameLabel?.text = user?.firstName
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    nameLabel?.text = user?.firstName
  }
  
  @IBAction func detailTapped(_ sender: UIButton) {
    delegate?.cell?(self, detailButtonTapped: sender)
  }

  override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    super.apply(layoutAttributes)
    let attributes = layoutAttributes as! UserCollectionViewLayoutAttributes
    someLabel?.text = "\(attributes.row) - \(attributes.column)"
    height = attributes.height
  }
}
