//
//  PetInfoViewController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 3/17/16.
//  Copyright © 2016 Techshed. All rights reserved.
//

import UIKit

class PetInfoViewController: UIViewController {
  
  @IBOutlet weak var dismissButton: UIButton!
  @IBOutlet weak var imageView: UIImageView!
  
  var pet: PetCard!
  
  @IBAction func dismissButtonTapped(sender: UIButton) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    imageView.image = pet.image
  }
}
