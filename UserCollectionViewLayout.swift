//
//  UserCollectionViewLayout.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 10/26/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit

class UserCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
  
  var row = 0
  var column = 0
  var height: CGFloat = 0.0
  
  override func copy(with zone: NSZone?) -> Any {
    let copy = super.copy(with: zone) as! UserCollectionViewLayoutAttributes
    copy.row = row
    copy.column = column
    copy.height = height
    return copy
  }
  
  override func isEqual(_ object: Any?) -> Bool {
    if let object = object as? UserCollectionViewLayoutAttributes {
      if row != object.row || column != object.column || height != object.height {
        return false
      }
      return super.isEqual(object)
    }
    return false
  }
}

protocol UserCollectionViewLayoutDelegate: UICollectionViewDelegate {
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout userCollectionViewLayout: UserCollectionViewLayout,
    heightForUserAtIndexPath indexPath: IndexPath) -> CGFloat
}

@IBDesignable
class UserCollectionViewLayout: UICollectionViewLayout {

  @IBInspectable var numberOfItemsInRow = 1 {
    didSet {
      if numberOfItemsInRow < 1 {
        numberOfItemsInRow = 1
      }
    }
  }
  
  var animatingIndexPath: IndexPath!
  
  fileprivate var contentHeight: CGFloat = 0.0
  fileprivate var cachedAttributes = [UserCollectionViewLayoutAttributes]()
  
  @IBInspectable weak var delegate: UserCollectionViewLayoutDelegate!
  
  fileprivate var numberOfItemsInSection: Int {
    return collectionView?.numberOfItems(inSection: 0) ?? 0
  }
  
  fileprivate var contentWidth: CGFloat {
    return (collectionView?.bounds ?? CGRect.zero).width
  }
  
  fileprivate var itemWidth: CGFloat {
    return contentWidth / CGFloat(numberOfItemsInRow)
  }
  
  override var collectionViewContentSize : CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }
  
  override class var layoutAttributesClass : AnyClass {
    return UserCollectionViewLayoutAttributes.self
  }

  override func prepare() {
    if cachedAttributes.isEmpty {
      
      let xOffsets = (0..<numberOfItemsInRow).map { (index) -> CGFloat in
        return CGFloat(index) * itemWidth
      }
      
      var yOffsets = Array(repeating: CGFloat(0), count: numberOfItemsInRow)
      var column = 0
      
      for item in 0..<numberOfItemsInSection {
        let indexPath = IndexPath(item: item, section: 0)
        let attributes = UserCollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)

        let height = delegate!.collectionView(collectionView!, layout: self, heightForUserAtIndexPath: indexPath)

        var yOffset = height
        if let animatingIndexPath = animatingIndexPath where indexPath == animatingIndexPath {
          yOffset =  yOffset + 50.0
        }
        let frame = CGRect(x: xOffsets[column], y: yOffsets[column], width: itemWidth, height: yOffset)

        attributes.frame = frame
        attributes.row = item
        attributes.column = column
        attributes.height = height
          
        cachedAttributes.append(attributes)
        
        yOffsets[column] = yOffsets[column] + yOffset
        
        column = (column >= numberOfItemsInRow - 1) ? 0 : column + 1
        contentHeight = max(contentHeight, frame.maxY)
      }
    }
  }
  
  override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    if let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) {
      if let animatingIndexPath = animatingIndexPath where itemIndexPath == animatingIndexPath {
        attributes.frame.size.height = delegate!.collectionView(collectionView!, layout: self, heightForUserAtIndexPath: itemIndexPath)
      }
      return attributes
    }
    return nil
  }

  override func invalidateLayout() {
    cachedAttributes.removeAll()
    contentHeight = 0
    super.invalidateLayout()
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return cachedAttributes.filter { (attribute) -> Bool in
      return rect.intersects(attribute.frame)
    }
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return cachedAttributes.filter { (attribute) -> Bool in
      return attribute.indexPath == indexPath
    }.first
  }
}
