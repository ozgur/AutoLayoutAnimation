//
//  CAScrollViewController.swift
//  Slide to reveal
//
//  Created by Ozgur Vatansever on 11/9/15.
//  Copyright © 2015 Underplot ltd. All rights reserved.
//


import UIKit

class CAScrollViewController: UIViewController {
  
  fileprivate static let trainImage: UIImage! = UIImage(named: "train-invasivecode")
  fileprivate static let skyImage: UIImage! = UIImage(named: "sky-invasivecode")
  
  lazy var view2: UIView = { [unowned self] in
    let view2 = UIView(frame: CGRect.zero)
    view2.backgroundColor = .white
    
    let label = UILabel()
    label.text = self.name
    
    return view2
  }()
  
  var name: String {
    return "ozgur"
  }
  
  lazy var scrollLayer: CAScrollLayer = { [unowned self] in
    let layer = CAScrollLayer()
    
    layer.bounds = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.size.width, height:self.view.bounds.size.height) // 9
    layer.position = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height/2) // 10

    layer.borderColor = UIColor.black.cgColor
    layer.borderWidth = 5.0
    layer.scrollMode = kCAScrollHorizontally

    return layer
  }()
  
 lazy var scrollLayerTop: CAScrollLayer = { [unowned self] in
    let scrollLayerTop = CAScrollLayer() // 22
    scrollLayerTop.bounds = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.size.width, height: self.view.bounds.size.height) // 23
    scrollLayerTop.position = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height/2) // 24
    scrollLayerTop.scrollMode = kCAScrollVertically // 25
    return scrollLayerTop
  }()
  
  let trainLayer: CALayer = {
    let layer = CALayer()
    let image: UIImage! = UIImage(named: "train-invasivecode")

    layer.bounds = CGRect(origin: CGPoint.zero, size: image.size)
    layer.contents = image.cgImage
    layer.position = CGPoint(x: image.size.width / 2.0, y: image.size.height / 2.0)
    
    return layer
  }()
  
  let skyLayer: CALayer = {
    let layer = CALayer()
    let image: UIImage! = UIImage(named: "sky-invasivecode")
    
    layer.bounds = CGRect(origin: CGPoint.zero, size: image.size)
    layer.contents = image.cgImage
    layer.position = CGPoint(x: image.size.width / 2.0, y: image.size.height / 2.0)
    
    return layer
  }()
  
  var animator: CADisplayLink!
  var skyTranslation: CGFloat = 0.0
  var trainTranslation: CGFloat = 0.0
  var moveUp : Bool = true

  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Train"
    
    edgesForExtendedLayout = UIRectEdge()
    view.backgroundColor = UIColor.white

    scrollLayer.addSublayer(skyLayer)
    view.layer.addSublayer(scrollLayer)

    let image: UIImage! = UIImage(named: "train-invasivecode")
    trainLayer.position = CGPoint(x: view.bounds.size.width/2, y: (view.bounds.size.height - image.size.height / 2))
    scrollLayerTop.addSublayer(trainLayer)  // 21
    view.layer.addSublayer(scrollLayerTop)  // 20
    
    animator = CADisplayLink(target: self, selector: "scrollLayerScroll")
    animator.frameInterval = 10
  }
  
  func scrollLayerScroll() {
    scrollLayer.scroll(CGPoint(x: skyTranslation, y: 0.0))
    
    if skyTranslation >= skyLayer.bounds.width {
      scrollLayer.scroll(CGPoint.zero)
      skyTranslation = 0
    }
    skyTranslation = skyTranslation + 10
    
    if (moveUp != false) {
      scrollLayerTop.scroll(to: CGPoint(x: 0.0, y: 10.0))
      moveUp = false
    } else {
      scrollLayerTop.scroll(to: CGPoint(x: 0.0, y: -10.0))
      moveUp = true
    }
    
    /*
    let newPoint = CGPoint(x: translation, y: 0.0)
    scrollLayer.scrollPoint(newPoint)
    if translation <= -scrollLayer.bounds.width {
      translation = CAScrollViewController.trainImage.size.width
      scrollLayer.scrollPoint(CGPoint(x: translation, y: 0.0))
    }
    translation -= 10
    */
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    animator.invalidate()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    animator.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
  }
  
  deinit {
    animator.invalidate()
    animator = nil
  }
}
