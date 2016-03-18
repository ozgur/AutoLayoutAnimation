//
//  FlipPresentAnimationController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 3/17/16.
//  Copyright © 2016 Techshed. All rights reserved.
//

import UIKit

class FlipPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

  var originFrame = CGRectZero
  
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
    
    let snapshotView = toViewController.view.snapshotViewAfterScreenUpdates(true)
    snapshotView.frame = originFrame
    
    snapshotView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 0, 1, 0)
    snapshotView.layer.cornerRadius = 25
    snapshotView.layer.masksToBounds = true
    
    containerView.addSubview(toViewController.view)
    containerView.addSubview(snapshotView)
    
    var transform = CATransform3DIdentity
    transform.m34 = -0.002
    containerView.layer.sublayerTransform = transform
    
    toViewController.view.hidden = true
    
    let finalFrame = transitionContext.finalFrameForViewController(toViewController)
    let duration = self.transitionDuration(transitionContext)
    
    UIView.animateKeyframesWithDuration(
      duration,
      delay: 0,
      options: .CalculationModeCubic,
      animations: {

        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1/3) {
          fromViewController.view.layer.transform = CATransform3DMakeRotation(CGFloat(-M_PI_2), 0, 1, 0)
        }
        
        UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 1/3) {
          snapshotView.layer.transform = CATransform3DIdentity
        }
        
        UIView.addKeyframeWithRelativeStartTime(2/3, relativeDuration: 1/3) {
          snapshotView.frame = finalFrame
        }
      },
      completion: { _ in
        snapshotView.removeFromSuperview()
        fromViewController.view.layer.transform = CATransform3DIdentity
        toViewController.view.hidden = false
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
    })
  }
}
