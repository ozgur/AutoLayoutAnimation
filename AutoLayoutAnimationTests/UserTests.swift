//
//  UserTests.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 10/25/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import XCTest
import Quick
import Nimble

@testable import AutoLayoutAnimation

class UserTests: XCTestCase {
  
  let dataSource = UserDataSource()
  
  override func setUp() {
    super.setUp()
    
    dataSource.loadUsersFromPlist(named: "Users")
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testCount() {
    XCTAssertGreaterThan(dataSource.count, 0, "User count should be greater than 0")
  }
  
  func testAddUserFails() {
    let user = dataSource[0]
    XCTAssertFalse(dataSource.addUser(user), "User should not be added")
  }
  
  func testAddUserSucceeds() {
    let user = User(firstName: "John", lastName: "Doe", userId: 0, city: "New York")
    XCTAssertTrue(dataSource.addUser(user), "User should be added")
  }
  
  func testRemoveUserFails() {
    let user = User(firstName: "John", lastName: "Doe", userId: 0, city: "New York")
    XCTAssertFalse(dataSource.removeUser(user), "User should not be removed")
  }
  
  func testRemoveUserSucceeds() {
    let user = dataSource[0]
    XCTAssertTrue(dataSource.removeUser(user), "User should be removed")
  }
  
  func testFullName() {
    let user = User(firstName: "John", lastName: "Doe", userId: 0, city: "New York")

    XCTAssertEqual(user.fullName, "John Doe")

    user.firstName = "John"
    user.lastName = ""
    XCTAssertEqual(user.fullName, "John")
    
    user.firstName = ""
    user.lastName = "Doe"
    XCTAssertEqual(user.fullName, "Doe")

    user.firstName = ""
    user.lastName = ""
    XCTAssertEqual(user.fullName, "")
  }
}

class UserDataManagerSpec: QuickSpec {
  
  var userDataHTTPResponse: UserDataHTTPResponse!
  let dataManager = UserDataManager()

  override func spec() {
    
    describe("Testing UserDataManager.requestUsers") {
      
      it("will test success") {
        self.dataManager.requestUsers("Users") { response in
          switch response {
          case .success:
            self.userDataHTTPResponse = response
          default:
            self.userDataHTTPResponse = nil
          }
        }
        expect(self.userDataHTTPResponse).toEventuallyNot(beNil(), timeout: 5)
      }
      
      it("will test success") {
        
        self.dataManager.requestUsers("XXX") { response in
          switch response {
          case .error:
            self.userDataHTTPResponse = response
          default:
            self.userDataHTTPResponse = nil
          }
        }
        expect(self.userDataHTTPResponse).toEventuallyNot(beNil(), timeout: 3)
      }
    }
  }
}
