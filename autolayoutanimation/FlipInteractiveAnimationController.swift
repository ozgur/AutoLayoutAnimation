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
  fileprivate var completesTransition: Bool = false
  fileprivate weak var viewController: UIViewController!
  
  func wireToViewController(_ viewController: UIViewController) {
    self.viewController = viewController
    
    let gestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "handlePan:")
    gestureRecognizer.edges = .left
    viewController.view.addGestureRecognizer(gestureRecognizer)
  }
  
  func handlePan(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
    let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
    
    let progress = fminf(fmaxf(0, Float(translation.x / 200.0)), 1)
    
    switch gestureRecognizer.state {
    case .began:
      inProgress = true
      viewController.dismiss(animated: true, completion: nil)
    case .changed:
      completesTransition = progress > 0.5
      self.update(CGFloat(progress))
    case .cancelled:
      inProgress = false
      self.cancel()
    case .ended:
      inProgress = false
      if completesTransition {
        self.finish()
      }
      else {
        self.cancel()
      }
    default:
      return
    }
  }
}
