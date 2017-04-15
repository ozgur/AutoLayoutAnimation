//
//  Array+Additions.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 3/17/16.
//  Copyright © 2016 Techshed. All rights reserved.
//

import UIKit

extension Array { 
  func indexOf<Element: Equatable>(_ item: Element) -> Int? {
    return self.index(where: { (object) -> Bool in
      return (object as! Element) == item
    })
  }
}
