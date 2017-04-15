//
//  NestedObjectMapperViewController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 10/20/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit
import ObjectMapper
import Cartography

extension Mapper {
  
}

class NestedObjectMapperViewController: UIViewController {
  
  @IBOutlet fileprivate weak var imageView: UIImageView!

  convenience init() {
    self.init(nibName: "NestedObjectMapperViewController", bundle: Bundle.main)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    edgesForExtendedLayout = UIRectEdge()
    title = "Nesting Objects"
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    let city = Mapper<City>().map(readJSONFile("City"))
    imageView.image = city?.image
  }
}

class ZipcodeTransform: TransformType {
  typealias Object = [String]
  typealias JSON = String

  func transformFromJSON(_ value: AnyObject?) -> [String]? {
    if let value = value as? String {
      return value.components(separatedBy: ",").map { value in
        return value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
      }
    }
    return nil
  }
  
  func transformToJSON(_ value: [String]?) -> String? {
    guard let value = value else {
      return nil
    }
    return value.joined(separator: ",")
  }
}

class City: Mappable {
  var name: String!
  var state: String!
  var population: Int!
  var zipcode: [String]!
  var image: UIImage!
  var elevation: Float!
  var water: Float!
  var land: Float!
  var government: CityGovernment!
  
  required init?(_ map: Map) {
    
  }
  
  func mapping(_ map: Map) {
    name <- map["name"]
    state <- map["state"]
    population <- map["population"]
    zipcode <- (map["zipcode"], ZipcodeTransform())
    elevation <- map["area.elevation"]
    water <- map["area.water"]
    land <- map["area.land"]
    government <- map["government"]
    
    let imageTransform = TransformOf<UIImage, String>(
      fromJSON: { (imageName) -> UIImage? in
        guard let imageName = imageName else {
          return nil
        }
        let image = UIImage(named: imageName)
        image?.accessibilityIdentifier = imageName
        return image
      },
      toJSON: { (image) -> String? in
        return image?.accessibilityIdentifier
      }
    )
    image <- (map["image"], imageTransform)
  }
}

class CityGovernment: CustomStringConvertible, Mappable {
  var type: String!
  var mayor: String!
  var supervisors: [String]!
  
  required init?(_ map: Map) {
    
  }
  
  func mapping(_ map: Map) {
    type <- map["type"]
    mayor <- map["mayor"]
    supervisors <- map["supervisors"]
  }
  
  var description: String {
    return "<Government: \(type) | \(mayor)>"
  }
}

