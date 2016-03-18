//
//  PetViewController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 3/17/16.
//  Copyright © 2016 Techshed. All rights reserved.
//

import UIKit

class PetViewController: UIViewController, UIViewControllerTransitioningDelegate {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  
  private let flipPresentAnimationController = FlipPresentAnimationController()
  private let flipDismissAnimationController = FlipDismissAnimationController()
  private let flipInteractiveAnimationController = FlipInteractiveAnimationController()
  
  @IBOutlet weak var contentView: UIView!
  var pet: PetCard!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    contentView.layer.cornerRadius = 25
    contentView.layer.masksToBounds = true

    titleLabel.text = pet.name
    subtitleLabel.text = pet.description
    
    contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
  }
  
  func handleTap(gestureRecognizer: UIGestureRecognizer) {
    let viewController = PetInfoViewController()
    viewController.pet = pet
    viewController.transitioningDelegate = self
    flipInteractiveAnimationController.wireToViewController(viewController)
    self.presentViewController(viewController, animated: true, completion: nil)
  }
  
  func animationControllerForPresentedController(
    presented: UIViewController,
    presentingController presenting: UIViewController,
    sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      flipPresentAnimationController.originFrame = contentView.superview!.convertRect(contentView.frame, toView: navigationController?.view ?? contentView.superview)
      return flipPresentAnimationController
  }
  
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    flipDismissAnimationController.destinationFrame = contentView.superview!.convertRect(contentView.frame, toView: navigationController?.view ?? contentView.superview)
    return flipDismissAnimationController
  }
  
  func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return flipInteractiveAnimationController.inProgress ? flipInteractiveAnimationController : nil
  }
}