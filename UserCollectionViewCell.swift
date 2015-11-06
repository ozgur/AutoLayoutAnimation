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
  optional func cell(cell: UserCollectionViewCell, detailButtonTapped button: UIButton)
}

class UserCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var someLabel: UILabel!
  
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
  
  @IBAction func detailTapped(sender: UIButton) {
    delegate?.cell?(self, detailButtonTapped: sender)
  }

  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
    super.applyLayoutAttributes(layoutAttributes)
    let attributes = layoutAttributes as! UserCollectionViewLayoutAttributes
    someLabel?.text = "\(attributes.row) - \(attributes.column)"
    height = attributes.height
  }
}
