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
  
  fileprivate let flipPresentAnimationController = FlipPresentAnimationController()
  fileprivate let flipDismissAnimationController = FlipDismissAnimationController()
  fileprivate let flipInteractiveAnimationController = FlipInteractiveAnimationController()
  
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
  
  func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
    let viewController = PetInfoViewController()
    viewController.pet = pet
    viewController.transitioningDelegate = self
    flipInteractiveAnimationController.wireToViewController(viewController)
    self.present(viewController, animated: true, completion: nil)
  }
  
  func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      flipPresentAnimationController.originFrame = contentView.superview!.convert(contentView.frame, to: navigationController?.view ?? contentView.superview)
      return flipPresentAnimationController
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    flipDismissAnimationController.destinationFrame = contentView.superview!.convert(contentView.frame, to: navigationController?.view ?? contentView.superview)
    return flipDismissAnimationController
  }
  
  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return flipInteractiveAnimationController.inProgress ? flipInteractiveAnimationController : nil
  }
}
