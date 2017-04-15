//
//  Person.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 11/19/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import Foundation

public protocol Throwable {
  static var domain: String { get }
}

class Student: Throwable {
  static var domain: String {
    return "com.student.error"
  }
}

public struct MPError {
  
  public enum Code: Int {
    case invalidHTMLError = -999
    case validationError = -998
  }
  
  static func errorWithThrowable<T: Throwable>(_ throwable: T.Type, code: Code, description: String?) -> NSError {
    let userInfo: [String: String]? = description != nil ? [NSLocalizedDescriptionKey: description!] : nil
    return NSError(domain: throwable.domain, code: code.rawValue, userInfo: userInfo)
  }
}
