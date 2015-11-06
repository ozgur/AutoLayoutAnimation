//
//  CoreAnimationViewController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 10/29/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit
import Cartography

class CoreAnimationViewController: UIViewController {

  let nameConstraints = ConstraintGroup()
  let passwordConstraints = ConstraintGroup()
  
  let nameTextField: UITextField = {
    let textField = UITextField(frame: CGRectZero)
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholder = "Type your name"
    textField.borderStyle = UITextBorderStyle.RoundedRect
    textField.defaultTextAttributes = [
      NSForegroundColorAttributeName: UIColor.darkTextColor(),
      NSFontAttributeName: UIFont.boldSystemFontOfSize(15.0),
      NSBackgroundColorAttributeName: UIColor.lightGrayColor()
    ]
    return textField
  }()
  
  let passwordTextField: UITextField = {
    let textField = UITextField(frame: CGRectZero)
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholder = "Type your password"
    textField.borderStyle = UITextBorderStyle.RoundedRect
    textField.secureTextEntry = true
    textField.defaultTextAttributes = [
      NSForegroundColorAttributeName: UIColor.darkTextColor(),
      NSFontAttributeName: UIFont.boldSystemFontOfSize(15.0),
      NSBackgroundColorAttributeName: UIColor.lightGrayColor()
    ]
    return textField
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    edgesForExtendedLayout = UIRectEdge.None
    view.backgroundColor = .whiteColor()
    title = "Core Animation"
    
    view.addSubview(nameTextField)
    view.addSubview(passwordTextField)

    constrain(nameTextField, v2: passwordTextField, v3: view) { nameTextField, passwordTextField, view in
      nameTextField.top == view.top + 50.0
      nameTextField.width == view.width - 40.0

      passwordTextField.top == nameTextField.bottom + 10.0
      passwordTextField.width == nameTextField.width
    }
    
    constrain(nameTextField, v2: view, replace: nameConstraints) { nameTextField, view in
      nameTextField.trailing == view.leading
    }
    
    constrain(passwordTextField, v2: view, replace: passwordConstraints) { passwordTextField, view in
      passwordTextField.trailing == view.leading
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    let animateFromLeft = CABasicAnimation(keyPath: "position.x")
    animateFromLeft.fromValue = -CGRectGetMidX(view.frame)
    animateFromLeft.toValue = CGRectGetMidX(view.frame)
    animateFromLeft.duration = 0.3
    animateFromLeft.delegate = self
    
    animateFromLeft.setValue(nameTextField.layer, forKey: "layer")
    nameTextField.layer.addAnimation(animateFromLeft, forKey: "animateFromLeft")
    
    animateFromLeft.beginTime = CACurrentMediaTime() + 0.2 // delay

    animateFromLeft.setValue(passwordTextField.layer, forKey: "layer")
    passwordTextField.layer.addAnimation(animateFromLeft, forKey: "animateFromLeft")
    
    /**
    *  The below logic is equal to what CA animation is doing above.
    */
    /*
    constrain(nameTextField, v2: view, replace: nameConstraints) { nameTextField, view in
      nameTextField.centerX == view.centerX
    }
    
    UIView.animateWithDuration(0.3, animations: view.layoutIfNeeded)
    
    constrain(passwordTextField, v2: view, replace: passwordConstraints) { passwordTextField, view in
      passwordTextField.centerX == view.centerX
    }
    
    UIView.animateWithDuration(0.3, delay: 0.3, options: [], animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  */
  }
}

extension CoreAnimationViewController {

  override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
    if let layer = anim.valueForKey("layer") as? CALayer {
      switch layer {
      case nameTextField.layer:
        constrain(nameTextField, v2: view, replace: nameConstraints) { nameTextField, view in
          nameTextField.centerX == view.centerX
        }
      case passwordTextField.layer:
        constrain(passwordTextField, v2: view, replace: passwordConstraints) { passwordTextField, view in
          passwordTextField.centerX == view.centerX
        }
      default:
        break
      }
    }
  }
}
