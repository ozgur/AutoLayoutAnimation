//
//  UserDataSource.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 10/25/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit
import AddressBook

class UserDataSource {
  
  fileprivate var users = [User]()
  
  var count: Int {
    return users.count
  }
  
  subscript(index: Int) -> User {
    return users[index]
  }
  
  func addUser(_ user: User) -> Bool {
    if users.contains(user) {
      return false
    }
    users.append(user)
    return true
  }
  
  func removeUser(_ user: User) -> Bool {
    guard let index = users.index(of: user) else {
      return false
    }
    users.remove(at: index)
    return true
  }

  func loadUsersFromPlist(named: String) -> [User]? {
    let mainBundle = Bundle.main
    guard let path = mainBundle.path(forResource: named, ofType: "plist"),
      content = NSArray(contentsOfFile: path) as? [[String: String]] else {
        return nil
    }
    users = content.map { (dict) -> User in
      return User(data: dict)
    }
    return users
  }
}

class User: NSObject {
  
  var firstName: String
  var lastName: String
  var userId: Int
  var city: String
  
  var fullName: String {
    let record = ABPersonCreate().takeRetainedValue() as ABRecordRef
    ABRecordSetValue(record, kABPersonFirstNameProperty, firstName, nil)
    ABRecordSetValue(record, kABPersonLastNameProperty, lastName, nil)
    
    guard let name = ABRecordCopyCompositeName(record)?.takeRetainedValue() else {
      return ""
    }
    return name as String
  }
  
  override var description: String {
    return "<User: \(fullName)>"
  }
  
  init(firstName: String, lastName: String, userId: Int, city: String) {
    self.firstName = firstName
    self.lastName = lastName
    self.userId = userId
    self.city = city
  }
  
  convenience init(data: [String: String]) {
    let firstName = data["firstname"]!
    let lastName = data["lastname"]!
    let userId = Int(data["id"]!)!
    let city = data["city"]!
    
    self.init(firstName: firstName, lastName: lastName, userId: userId, city: city)
  }
}

func ==(lhs: User, rhs: User) -> Bool {
  return lhs.userId == rhs.userId
}
