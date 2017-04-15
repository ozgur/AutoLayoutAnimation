//
//  UserDataManager.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 10/27/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit

enum UserDataHTTPResponse {
  case success([User])
  case error(NSError)
}

class UserDataManager {

  fileprivate let dataSource = UserDataSource()
  fileprivate static let shared = UserDataManager()
  
  class func sharedInstance() -> UserDataManager {
    return self.shared
  }
  
  func requestUsers(_ plist: String, completion: (UserDataHTTPResponse) -> Void) {
    execute(delay: 1.0, repeating: false) {
      if let users = self.dataSource.loadUsersFromPlist(named: plist) {
        completion(.success(users))
      }
      else {
        let userInfo = [
          NSLocalizedDescriptionKey: "Plist not found or failed to parse.",
          NSLocalizedFailureReasonErrorKey: "Plist not found or failed to parse."
        ]
        completion(.error(NSError(domain: "UserDataManagerErrorDomain", code: -999, userInfo: userInfo)))
      }
    }
  }
}
