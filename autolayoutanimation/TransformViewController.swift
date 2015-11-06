//
//  TransformViewController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 10/16/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit
import Cartography

class TransformViewController: UIViewController {

  private let firstLabel: UILabel = {
    let label = UILabel(frame: CGRectZero)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "UA 711"
    label.numberOfLines = 1
    label.textColor = UIColor.whiteColor()
    label.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 25)
    return label
  }()
  
  private let secondLabel: UILabel = {
    let label = UILabel(frame: CGRectZero)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = NSTextAlignment.Center
    label.text = "San Francisco"
    label.numberOfLines = 1
    label.textColor = UIColor.whiteColor()
    label.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 25)
    return label
  }()
  
  private let thirdLabel: UILabel = {
    let label = UILabel(frame: CGRectZero)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = NSTextAlignment.Center
    label.text = "Ozgur Vatansever"
    label.numberOfLines = 1
    label.textColor = UIColor.whiteColor()
    label.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 25)
    return label
  }()
  
  private let planeView = UIImageView(image: UIImage(named: "plane"))
  
  private var constraints = ConstraintGroup()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    edgesForExtendedLayout = UIRectEdge.None
    view.backgroundColor = UIColor.darkTextColor()
    title = "Animating Transform Matrix"
    
    planeView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(firstLabel)
    view.addSubview(secondLabel)
    view.addSubview(thirdLabel)
    view.addSubview(planeView)
    
    constrain(firstLabel, v2: view) { firstLabel, view in
      firstLabel.top == view.top + 30
      firstLabel.leading == view.leading + 30
      firstLabel.width == 120
    }
    
    constrain(planeView, v2: view, replace: constraints) { planeView, view in
      planeView.center == view.center
    }
    
    constrain(secondLabel, v2: planeView, v3: view) { secondLabel, planeView, view in
      secondLabel.top == planeView.top - 100.0
      secondLabel.leading == view.leading
      secondLabel.trailing == view.trailing
    }
    
    constrain(thirdLabel, v2: view) { thirdLabel, view in
      thirdLabel.leading == view.leading - 30.0
      thirdLabel.bottom == view.bottom - 30.0
      thirdLabel.centerX == view.centerX
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    execute(delay: 1.0, repeating: false) {
      self.transformFirstLabel(self.firstLabel, withText: "TK 054", direction: 1)
      self.transformSecondLabel(self.secondLabel, withText: "Istanbul", offset: CGPoint(x: 20, y: 20))
      self.rotateThirdLabel(self.thirdLabel)
      self.takeOffPlane(self.planeView)
    }
  }

  private func takeOffPlane(imageView: UIImageView) {
    
    let newImageView = UIImageView(image: imageView.image)
    newImageView.center = imageView.center
    imageView.superview?.insertSubview(newImageView, aboveSubview: newImageView)
    
    imageView.hidden = true
    
    UIView.animateKeyframesWithDuration(
      1.5,
      delay: 0.0,
      options: UIViewKeyframeAnimationOptions.BeginFromCurrentState,
      animations: {
        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.25) {
          newImageView.frame.origin.y -= 5.0
          newImageView.frame.origin.x += 80.0
        }
        
        UIView.addKeyframeWithRelativeStartTime(0.25, relativeDuration: 0.25) {
          newImageView.frame.origin.y -= 50.0
          newImageView.frame.origin.x += 100.0
          newImageView.alpha = 0.0
        }
        
        UIView.addKeyframeWithRelativeStartTime(0.1, relativeDuration: 0.4) {
          newImageView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_4 / 2))
        }

        UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.0001) {
          newImageView.transform = CGAffineTransformIdentity
          newImageView.center = CGPoint(x: 0.0, y: imageView.center.y)
        }
        
        UIView.addKeyframeWithRelativeStartTime(0.51, relativeDuration: 0.49) {
          newImageView.center = imageView.center
          newImageView.alpha = 1.0
        }
      },
      completion: { _ in
        imageView.hidden = false
        newImageView.removeFromSuperview()

        execute(delay: 0.25, repeating: false) {
          self.takeOffPlane(imageView)
        }
      }
    )
  }
  
  private func transformSecondLabel(label: UILabel, withText text: String, offset: CGPoint) {
    let newLabel = UILabel(frame: label.frame)
    newLabel.textAlignment = label.textAlignment
    newLabel.font = label.font
    newLabel.numberOfLines = label.numberOfLines
    newLabel.textColor = label.textColor
    newLabel.backgroundColor = label.backgroundColor
    newLabel.alpha = 0.0
    newLabel.text = text
    newLabel.transform = CGAffineTransformMakeTranslation(offset.x, offset.y)
    
    label.superview?.addSubview(newLabel)
    
    UIView.animateWithDuration(0.75, delay: 0.0, options: .BeginFromCurrentState, animations: {
      label.transform = CGAffineTransformMakeTranslation(offset.x, offset.y)
      label.alpha = 0.0
    }, completion: nil)
    
    UIView.animateWithDuration(
      0.75,
      delay: 0.0,
      options: UIViewAnimationOptions.BeginFromCurrentState,
      animations: {
        newLabel.transform = CGAffineTransformIdentity
        newLabel.alpha = 1.0
      },
      completion: { _ in
        label.transform = CGAffineTransformIdentity
        label.alpha = 1.0
        let oldText = label.text!
        label.text = newLabel.text
        newLabel.removeFromSuperview()
        
        execute(delay: 1.0, repeating: false) {
          self.transformSecondLabel(label, withText: oldText, offset: offset)
        }
      }
    )
  }

  private func transformFirstLabel(label: UILabel, withText text: String, direction: Int) {
    
    let originalFrame = label.frame
    
    let newLabel = UILabel(frame: originalFrame)
    let originalText = label.text!
    newLabel.text = text
    newLabel.numberOfLines = label.numberOfLines
    newLabel.font = label.font
    newLabel.textColor = label.textColor
    newLabel.backgroundColor = UIColor.clearColor()

    let newLabelOffset = CGFloat(direction) * originalFrame.height / 2.0
    
    newLabel.transform = CGAffineTransformConcat(
      CGAffineTransformMakeScale(1.0, 0.0),
      CGAffineTransformMakeTranslation(0.0, newLabelOffset)
    )

    label.superview!.addSubview(newLabel)
    
    UIView.animateWithDuration(0.75,
      delay: 0.0,
      options: [.BeginFromCurrentState, .CurveEaseOut],
      animations: { () -> Void in
        newLabel.transform = CGAffineTransformIdentity
        label.transform = CGAffineTransformConcat(
          CGAffineTransformMakeScale(1.0, 0.00001),
          CGAffineTransformMakeTranslation(0.0, -newLabelOffset)
        )
      },
      completion: { (finished: Bool) -> Void in
        label.text = newLabel.text
        label.transform = CGAffineTransformIdentity
        newLabel.removeFromSuperview()
        execute(delay: 1.0, repeating: false) {
          self.transformFirstLabel(self.firstLabel, withText: originalText, direction: -direction)
        }
      }
    )
  }
  
  func rotateThirdLabel(label: UILabel) {
    let animation = CAKeyframeAnimation(keyPath: "transform.rotation.x")
    animation.keyTimes = [0.0, 0.25, 0.50, 0.75, 1.0]
    animation.values = [0.0, -M_PI_2, 0.0, M_PI_2, 0.0]
    animation.duration = 0.6
    animation.repeatCount = 10
    
    thirdLabel.layer.addAnimation(animation, forKey: nil)
  }
}
