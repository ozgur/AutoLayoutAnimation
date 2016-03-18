//
//  FlipInteractiveAnimationController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 3/17/16.
//  Copyright © 2016 Techshed. All rights reserved.
//

import UIKit

class FlipInteractiveAnimationController: UIPercentDrivenInteractiveTransition {

  var inProgress: Bool = false
  private var completesTransition: Bool = false
  private weak var viewController: UIViewController!
  
  func wireToViewController(viewController: UIViewController) {
    self.viewController = viewController
    
    let gestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "handlePan:")
    gestureRecognizer.edges = .Left
    viewController.view.addGestureRecognizer(gestureRecognizer)
  }
  
  func handlePan(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
    let translation = gestureRecognizer.translationInView(gestureRecognizer.view!.superview!)
    
    let progress = fminf(fmaxf(0, Float(translation.x / 200.0)), 1)
    
    switch gestureRecognizer.state {
    case .Began:
      inProgress = true
      viewController.dismissViewControllerAnimated(true, completion: nil)
    case .Changed:
      completesTransition = progress > 0.5
      self.updateInteractiveTransition(CGFloat(progress))
    case .Cancelled:
      inProgress = false
      self.cancelInteractiveTransition()
    case .Ended:
      inProgress = false
      if completesTransition {
        self.finishInteractiveTransition()
      }
      else {
        self.cancelInteractiveTransition()
      }
    default:
      return
    }
  }
}
