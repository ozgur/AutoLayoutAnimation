//
//  FlipDismissAnimationController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 3/17/16.
//  Copyright © 2016 Techshed. All rights reserved.
//

import UIKit

class FlipDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

  var destinationFrame = CGRectZero
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 1.0
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    guard let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
      let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
      let containerView = transitionContext.containerView()
    else {
      return
    }
    
    let snapshotView = fromViewController.view.snapshotViewAfterScreenUpdates(true)
    snapshotView.layer.masksToBounds = true
    
    toViewController.view.layer.transform = CATransform3DMakeRotation(CGFloat(-M_PI_2), 0, 1, 0)

    containerView.addSubview(toViewController.view)
    containerView.addSubview(snapshotView)
    
    fromViewController.view.hidden = true

    var transform = CATransform3DIdentity
    transform.m34 = -0.002
    containerView.layer.sublayerTransform = transform
    
    let duration = self.transitionDuration(transitionContext)
    
    UIView.animateKeyframesWithDuration(
      duration,
      delay: 0.0,
      options: .CalculationModeCubic,
      animations: {
        
        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1/3) {
          snapshotView.frame = self.destinationFrame
          snapshotView.layer.cornerRadius = 25
        }
        
        UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 1/3) {
          snapshotView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 0, 1, 0)
        }

        UIView.addKeyframeWithRelativeStartTime(2/3, relativeDuration: 1/3) {
          toViewController.view.layer.transform = CATransform3DIdentity
        }
      },
      completion: { _ in
        snapshotView.removeFromSuperview()
        fromViewController.view.hidden = false
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
    })
  }
}
