//
//  BoxViewController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 10/14/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit
import Cartography

class BoxViewController: UIViewController {

  @IBOutlet private weak var topView: UIView!
  @IBOutlet private weak var bottomView: UIView!

  private var constraints = ConstraintGroup()

  override func viewDidLoad() {
    super.viewDidLoad()

    topView.translatesAutoresizingMaskIntoConstraints = false
    bottomView.translatesAutoresizingMaskIntoConstraints = false

    constrain(topView, v2: bottomView, v3: view) { topView, bottomView, view in

      topView.top == view.top + 20.0
      topView.leading == view.leading + 20.0
      topView.centerX == view.centerX
      
      align(leading: bottomView, rest: topView)
      align(trailing: bottomView, rest: topView)
      
      bottomView.bottom == view.bottom - 20.0
      bottomView.height == topView.height
    }
    
    constrain(topView, v2: bottomView, v3: view, replace: constraints) { topView, bottomView, view in
      topView.height == 100
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    constrain(topView, v2: bottomView, v3: view, replace: constraints) { topView, bottomView, view in
      topView.bottom == bottomView.top
    }
    
    UIView.animateWithDuration(1.0, animations: view.layoutIfNeeded)
  }
}

