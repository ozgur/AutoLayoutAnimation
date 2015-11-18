//
//  CAReplicatorViewController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 11/17/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit
import Cartography

private final class Constants {
  struct Replicator {
    static let instanceCount = 5
    static let interSpace: CGFloat = 8.0
    static let layerSize = CGSize(width: 50.0, height: 50.0)
  }
}

class CAReplicatorViewController: UIViewController {

  private let instanceLayer = CALayer()
  private let horizontalReplicateLayer = CAReplicatorLayer()
  private let verticalReplicateLayer = CAReplicatorLayer()
  private let depthReplicateLayer = CAReplicatorLayer()
  private let rootLayer = CALayer()

  private var centralPoint: CGPoint {
    return CGPoint(x: CGRectGetWidth(view.bounds) / 2.0, y: CGRectGetHeight(view.bounds) / 2.0)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.whiteColor()
    edgesForExtendedLayout = UIRectEdge.None
    title = "Replicator"
    
    self.setupLayers()

    rootLayer.addSublayer(depthReplicateLayer)
    depthReplicateLayer.addSublayer(verticalReplicateLayer)
    verticalReplicateLayer.addSublayer(horizontalReplicateLayer)
    horizontalReplicateLayer.addSublayer(instanceLayer)
    view.layer.addSublayer(rootLayer)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    //instanceLayer.removeAnimationForKey("waveAnimation")
    //instanceLayer.addAnimation(self.waveAnimation(), forKey: "waveAnimation")

    horizontalReplicateLayer.removeAnimationForKey("pushAnimation")
    horizontalReplicateLayer.addAnimation(self.pushAnimation(), forKey: "pushAnimation")
    
    depthReplicateLayer.removeAnimationForKey("rotateAnimation")
    depthReplicateLayer.addAnimation(self.rotateAnimation(), forKey: "rotateAnimation")
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    self.setupRootLayer()
  }
  
  // MARK: Layers
  
  private func setupRootLayer() {
    rootLayer.bounds = CGRect(origin: CGPointZero, size: view.bounds.size)
    rootLayer.position = centralPoint;
    
    rootLayer.sublayerTransform = CATransform3DConcat(
      CATransform3DMakeRotation(-CGFloat(M_PI) / 15.0, 1.0, 1.0, 0.0),
      CATransform3DMakeTranslation(30.0, 0, 0)
    )
    rootLayer.backgroundColor = UIColor.whiteColor().CGColor
  }

  private func setupInstanceLayer() {
    let interSpace = Constants.Replicator.interSpace
    let layerSize = Constants.Replicator.layerSize
    instanceLayer.position = CGPoint(x: layerSize.width / 2.0 + interSpace, y: layerSize.height / 2 + interSpace)
    instanceLayer.bounds = CGRect(origin: CGPointZero, size: layerSize)
    instanceLayer.backgroundColor = UIColor.whiteColor().CGColor
    instanceLayer.cornerRadius = 10.0
    instanceLayer.shadowColor = UIColor.blackColor().CGColor
    instanceLayer.shadowRadius = 4.0
    instanceLayer.shadowOffset = CGSize(width: 0, height: 3.0)
    instanceLayer.shadowOpacity = 0.8
    instanceLayer.opacity = 1.0
    instanceLayer.borderColor = UIColor.whiteColor().CGColor
    instanceLayer.borderWidth = 2.0
  }
  
  private func setupHorizontalReplicateLayer() {
    horizontalReplicateLayer.instanceCount = Constants.Replicator.instanceCount
    horizontalReplicateLayer.instanceDelay = 0.2
    horizontalReplicateLayer.instanceGreenOffset = -0.0625
    horizontalReplicateLayer.instanceRedOffset = -0.0625
    horizontalReplicateLayer.instanceBlueOffset = -0.0625
    //horizontalReplicateLayer.instanceAlphaOffset = -0.0625
    horizontalReplicateLayer.preservesDepth = true

    horizontalReplicateLayer.instanceTransform = CATransform3DMakeTranslation(
      Constants.Replicator.layerSize.width + Constants.Replicator.interSpace, 0, 0)
  }
  
  private func setupVerticalReplicateLayer() {
    verticalReplicateLayer.instanceCount = Constants.Replicator.instanceCount
    verticalReplicateLayer.instanceDelay = 0.2
    verticalReplicateLayer.instanceGreenOffset = -0.0625
    verticalReplicateLayer.instanceRedOffset = -0.0625
    verticalReplicateLayer.instanceBlueOffset = -0.0625
    //verticalReplicateLayer.instanceAlphaOffset = -0.0625
    verticalReplicateLayer.preservesDepth = true

    verticalReplicateLayer.instanceTransform = CATransform3DMakeTranslation(
      0, Constants.Replicator.layerSize.height + Constants.Replicator.interSpace, 0)
  }
  
  private func setupDepthReplicateLayer() {
    depthReplicateLayer.instanceCount = Constants.Replicator.instanceCount
    depthReplicateLayer.preservesDepth = true
    
    depthReplicateLayer.instanceTransform = CATransform3DMakeTranslation(
      0, 0, Constants.Replicator.layerSize.width + Constants.Replicator.interSpace)
  }
  
  private func setupLayers() {
    self.setupInstanceLayer()
    self.setupHorizontalReplicateLayer()
    self.setupVerticalReplicateLayer()
    self.setupDepthReplicateLayer()
    self.setupRootLayer()
  }
  
  // MARK: Animations
  
  private func pushAnimation() -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: "instanceTransform")
    animation.duration = 1.2
    animation.fromValue = NSValue(
      CATransform3D: CATransform3DMakeTranslation(Constants.Replicator.layerSize.width + Constants.Replicator.interSpace, 0, 0)
    )
    animation.toValue = NSValue(
      CATransform3D: CATransform3DMakeTranslation(Constants.Replicator.layerSize.width + (3 * Constants.Replicator.interSpace), 0, 0)
    )
    animation.autoreverses = true
    animation.repeatCount = Float(Int.max)
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    return animation
  }
  
  private func rotateAnimation() -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: "transform")
    
    animation.fromValue = NSValue(CATransform3D: CATransform3DRotate(CATransform3DIdentity, -0.2, 1.0, 0, 0))
    animation.toValue = NSValue(CATransform3D: CATransform3DRotate(CATransform3DIdentity, 0.2, 1.0, 0, 0))

    animation.duration = 3.0
    animation.autoreverses = true
    animation.repeatCount = Float(Int.max)
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    return animation
  }
  
  private func waveAnimation() -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: "transform")
    animation.duration = 1.5
    animation.fromValue = NSValue(
      CATransform3D: CATransform3DMakeTranslation(0, 0, 100)
    )
    animation.toValue = NSValue(
      CATransform3D: CATransform3DMakeTranslation(0, 0, -100)
    )
    animation.autoreverses = true
    animation.repeatCount = Float(Int.max)
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    return animation
  }
}
