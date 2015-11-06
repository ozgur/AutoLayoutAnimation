//
//  UserDataManager.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 10/27/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit

enum UserDataHTTPResponse {
  case Success([User])
  case Error(NSError)
}

class UserDataManager {

  private let dataSource = UserDataSource()
  private static let shared = UserDataManager()
  
  class func sharedInstance() -> UserDataManager {
    return self.shared
  }
  
  func requestUsers(plist: String, completion: (UserDataHTTPResponse) -> Void) {
    execute(delay: 2.0, repeating: false) {
      if let users = self.dataSource.loadUsersFromPlist(named: plist) {
        completion(.Success(users))
      }
      else {
        let userInfo = [
          NSLocalizedDescriptionKey: "Plist not found or failed to parse.",
          NSLocalizedFailureReasonErrorKey: "Plist not found or failed to parse."
        ]
        completion(.Error(NSError(domain: "UserDataManagerErrorDomain", code: -999, userInfo: userInfo)))
      }
    }
  }
}
