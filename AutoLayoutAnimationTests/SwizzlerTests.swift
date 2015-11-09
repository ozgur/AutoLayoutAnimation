//
//  SwizzlerTests.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 11/9/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import XCTest
import Quick
import Nimble

class SwizzledObject: NSObject {
  
  func originalInstanceMethod() -> String {
    return "originalInstanceMethod"
  }
  
  func swizzledInstanceMethod() -> String {
    return "swizzledInstanceMethod"
  }
  
  class func originalClassMethod() -> String {
    return "originalClassMethod"
  }
  
  class func swizzledClassMethod() -> String {
    return "swizzledClassMethod"
  }
}

class SwizzlerTests: QuickSpec {
  
  override func spec() {
    describe("Testing method swizzling") {
      
      it("will test swizzling an instance methods") {
        SwizzledObject.swizzleInstanceMethod("originalInstanceMethod", withMethod: "swizzledInstanceMethod")
        
        let swizzledObject = SwizzledObject()
        expect(swizzledObject.originalInstanceMethod()).to(equal("swizzledInstanceMethod"))
        expect(swizzledObject.swizzledInstanceMethod()).to(equal("originalInstanceMethod"))
      }
      
      it("will test swizzling class methods") {
        SwizzledObject.swizzleClassMethod("originalClassMethod", withMethod: "swizzledClassMethod")
        
        expect(SwizzledObject.originalClassMethod()).to(equal("swizzledClassMethod"))
        expect(SwizzledObject.swizzledClassMethod()).to(equal("originalClassMethod"))
      }
    }
  }
}
