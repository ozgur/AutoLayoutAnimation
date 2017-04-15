//
//  FlipDismissAnimationController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 3/17/16.
//  Copyright © 2016 Techshed. All rights reserved.
//

import UIKit

class FlipDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

  var destinationFrame = CGRect.zero
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 1.0
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
      let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
      let containerView = transitionContext.containerView
    else {
      return
    }
    
    let snapshotView = fromViewController.view.snapshotView(afterScreenUpdates: true)
    snapshotView.layer.masksToBounds = true
    
    toViewController.view.layer.transform = CATransform3DMakeRotation(CGFloat(-M_PI_2), 0, 1, 0)

    containerView.addSubview(toViewController.view)
    containerView.addSubview(snapshotView)
    
    fromViewController.view.isHidden = true

    var transform = CATransform3DIdentity
    transform.m34 = -0.002
    containerView.layer.sublayerTransform = transform
    
    let duration = self.transitionDuration(using: transitionContext)
    
    UIView.animateKeyframes(
      withDuration: duration,
      delay: 0.0,
      options: .calculationModeCubic,
      animations: {
        
        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/3) {
          snapshotView.frame = self.destinationFrame
          snapshotView.layer.cornerRadius = 25
        }
        
        UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 1/3) {
          snapshotView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 0, 1, 0)
        }

        UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3) {
          toViewController.view.layer.transform = CATransform3DIdentity
        }
      },
      completion: { _ in
        snapshotView.removeFromSuperview()
        fromViewController.view.isHidden = false
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    })
  }
}
