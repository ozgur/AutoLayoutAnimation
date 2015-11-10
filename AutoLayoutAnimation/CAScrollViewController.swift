//
//  CAScrollViewController.swift
//  Slide to reveal
//
//  Created by Ozgur Vatansever on 11/9/15.
//  Copyright © 2015 Underplot ltd. All rights reserved.
//

import UIKit
import Cartography

class ScrollingView: UIView {

  override class func layerClass() -> AnyClass {
    return CAScrollLayer.self
  }
}

class CAScrollViewController: UIViewController {
  
  private static let trainImage: UIImage! = UIImage(named: "train-invasivecode")

  let trainView: ScrollingView = {
    let view = ScrollingView(frame: CGRectZero)

    let image = CAScrollViewController.trainImage
    
    let layer = CALayer()
    layer.bounds = CGRect(origin: CGPointZero, size: image.size)
    layer.contents = image.CGImage
    layer.position = CGPoint(x: image.size.width / 2.0, y: image.size.height / 2.0)
    
    view.layer.addSublayer(layer)
    view.layer.borderWidth = 0.5
    view.layer.borderColor = UIColor.blackColor().CGColor
    return view
  }()
  
  var trainViewLayer: CAScrollLayer {
    return trainView.layer as! CAScrollLayer
  }
  
  var trainAnimator: CADisplayLink!
  var translation: CGFloat = 0.0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Train"
    
    edgesForExtendedLayout = .None

    view.backgroundColor = UIColor.whiteColor()
    view.addSubview(trainView)

    constrain(trainView, v2: view) { trainView, view in
      let trainImage = CAScrollViewController.trainImage

      trainView.centerX == view.centerX
      trainView.centerY == view.centerY - 150
      trainView.width == trainImage.size.width / 2.0
      trainView.height == trainImage.size.height
    }
    
    trainAnimator = CADisplayLink(target: self, selector: "trainViewLayerScroll")
    trainAnimator.frameInterval = 10
  }
  
  func trainViewLayerScroll() {
    let newPoint = CGPoint(x: translation, y: 0.0)
    trainViewLayer.scrollPoint(newPoint)
    if translation <= -trainViewLayer.bounds.width {
      translation = CAScrollViewController.trainImage.size.width
      trainViewLayer.scrollPoint(CGPoint(x: translation, y: 0.0))
    }
    translation -= 10
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    trainAnimator.invalidate()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    trainAnimator.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
  }
  
  deinit {
    trainAnimator.invalidate()
    trainAnimator = nil
  }
}
