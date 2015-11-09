//
//  AccessibilityIdentifierTests.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 11/9/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import XCTest
import Quick
import Nimble

@testable import AutoLayoutAnimation

class AccessibilityIdentifierTests: QuickSpec {
  
  override func spec() {
    describe("Testing accessibility identifiers of instance variables") {
      it("will test MainViewController") {
        
        let mainViewController = MainViewController()
        mainViewController.loadView()
        mainViewController.viewDidLoad()
        mainViewController.viewWillAppear(false)
        
        expect(mainViewController.assignedAllAccessibilityIdentifiersForInstanceVariables).to(equal(true))
        
        expect(mainViewController.designatedAccessibilityIdentifierForInstanceVariable("refreshView")).to(equal("MainViewController.refreshView"))
        expect(mainViewController.refreshView.accessibilityIdentifier).to(equal("MainViewController.refreshView"))
      }
      
      it("will test ImageViewController") {
        let imageViewController = ImageViewController()
        imageViewController.loadView()
        imageViewController.viewDidLoad()
        imageViewController.viewWillAppear(false)
        
        expect(imageViewController.assignedAllAccessibilityIdentifiersForInstanceVariables).to(equal(true))
        
        expect(imageViewController.scrollView.accessibilityIdentifier).to(equal("ImageViewController.scrollView"))
        expect(imageViewController.designatedAccessibilityIdentifierForInstanceVariable("scrollView")).to(equal("ImageViewController.scrollView"))

        expect(imageViewController.firstImageView.accessibilityIdentifier).to(equal("ImageViewController.firstImageView"))
        expect(imageViewController.designatedAccessibilityIdentifierForInstanceVariable("firstImageView")).to(equal("ImageViewController.firstImageView"))

        expect(imageViewController.secondImageView.accessibilityIdentifier).to(equal("ImageViewController.secondImageView"))
        expect(imageViewController.designatedAccessibilityIdentifierForInstanceVariable("secondImageView")).to(equal("ImageViewController.secondImageView"))

        expect(imageViewController.thirdImageView.accessibilityIdentifier).to(equal("ImageViewController.thirdImageView"))
        expect(imageViewController.designatedAccessibilityIdentifierForInstanceVariable("thirdImageView")).to(equal("ImageViewController.thirdImageView"))

        expect(imageViewController.textField.accessibilityIdentifier).to(equal("ImageViewController.textField"))
        expect(imageViewController.designatedAccessibilityIdentifierForInstanceVariable("textField")).to(equal("ImageViewController.textField"))
      }
      
      it("will text BoxViewController loaded from .xib") {
        let boxViewController = BoxViewController(nibName: "BoxViewController", bundle: nil)
        
        boxViewController.loadView()
        boxViewController.viewDidLoad()
        boxViewController.viewWillAppear(false)
        
        expect(boxViewController.assignedAllAccessibilityIdentifiersForInstanceVariables).to(equal(true))
        
        expect(boxViewController.topView.accessibilityIdentifier).to(equal("BoxViewController.topView"))
        expect(boxViewController.designatedAccessibilityIdentifierForInstanceVariable("topView")).to(equal("BoxViewController.topView"))
        
        expect(boxViewController.bottomView.accessibilityIdentifier).to(equal("BoxViewController.bottomView"))
        expect(boxViewController.designatedAccessibilityIdentifierForInstanceVariable("bottomView")).to(equal("BoxViewController.bottomView"))
      }
    }
  }
}
