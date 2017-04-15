//
//  ImageViewController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 11/1/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit
import Cartography

class ImageViewController: UIViewController {
  
  var firstImageView: UIImageView!
  var secondImageView: UIImageView!
  var thirdImageView: UIImageView!
  var scrollView: UIScrollView!
  var textField: UITextField!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    edgesForExtendedLayout = UIRectEdge()
    view.backgroundColor = .white
    
    title = "Scaling"
    
    print("Ozgur".length)
    
    scrollView = UIScrollView(frame: CGRect.zero)
    view.addSubview(scrollView)
    
    constrain(scrollView, v2: view) { scrollView, view in
      scrollView.leading == view.leading
      scrollView.trailing == view.trailing
      scrollView.top == view.top
      scrollView.bottom == view.bottom
    }

    let image = UIImage(named: "sanfrancisco@3x.jpg")!
    firstImageView = UIImageView(image: image)
    firstImageView.backgroundColor = .clear

    secondImageView = UIImageView(
      image: UIImage(image: image, scaleAspectFitTo: CGSize(width: 283.375, height: 201.0))
    )
    secondImageView.contentMode = .center
    secondImageView.backgroundColor = .clear
    
    thirdImageView = UIImageView(
      image: UIImage(image: image, scaleAspectFillTo: CGSize(width: 283.375, height: 150.0))
    )
    thirdImageView.contentMode = .center
    thirdImageView.backgroundColor = .clear

    scrollView.translatesAutoresizingMaskIntoConstraints = false
    firstImageView.translatesAutoresizingMaskIntoConstraints = false
    secondImageView.translatesAutoresizingMaskIntoConstraints = false
    thirdImageView.translatesAutoresizingMaskIntoConstraints = false

    scrollView.addSubview(firstImageView)
    scrollView.addSubview(secondImageView)
    scrollView.addSubview(thirdImageView)
    
    constrain(firstImageView, v2: secondImageView, v3: scrollView) { firstImageView, secondImageView, scrollView in
      firstImageView.top == scrollView.top + 9.0
      firstImageView.centerX == scrollView.centerX
      firstImageView.width == 283.375
      firstImageView.height == 201.0
      
      secondImageView.top == firstImageView.bottom + 9.0
      secondImageView.centerX == firstImageView.centerX
      secondImageView.width == 283.375
      secondImageView.height == 201.0
    }
    constrain(thirdImageView, v2: secondImageView, v3: scrollView) { thirdImageView, secondImageView, scrollView in
      thirdImageView.top == secondImageView.bottom + 9.0
      thirdImageView.centerX == secondImageView.centerX
      thirdImageView.width == 283.375
      thirdImageView.height == 150.0
    }
    
    textField = UITextField(frame: CGRect.zero)
    textField.borderStyle = .roundedRect
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.text = "aaaa"
    
    scrollView.addSubview(textField)
    
    constrain(textField, v2: thirdImageView, v3: scrollView) { textField, thirdImageView, scrollView in
      textField.top == thirdImageView.bottom + 9.0
      textField.centerX == scrollView.centerX
      textField.width == 283.375
      textField.height == 50.0
      textField.bottom == scrollView.bottom - 9.0
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
}
