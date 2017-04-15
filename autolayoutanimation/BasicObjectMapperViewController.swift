//
//  BasicObjectMapperViewController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 10/20/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit
import ObjectMapper

public func readJSONFile(_ resource: String) -> String? {
  let filePath = Bundle.main.path(forResource: resource, ofType: "json")
  do {
    let content = try NSString(contentsOfFile: filePath!, encoding: String.Encoding.utf8)
    return String(content)
  } catch {
    return nil
  }
}

class BasicObjectMapperViewController: UIViewController {

  @IBOutlet fileprivate weak var objectLabel: UILabel!
  @IBOutlet fileprivate weak var stringLabel: UILabel!
  @IBOutlet fileprivate weak var dictLabel: UILabel!
 
  convenience init() {
    self.init(nibName: "BasicObjectMapperViewController", bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    edgesForExtendedLayout = UIRectEdge()
    title = "Object Mapper"
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    let person = Mapper<Person>().map(readJSONFile("Person"))!
    print(person)
    
    let dictionary = Mapper().toJSON(person)
    print(dictionary)
    
    let content = Mapper().toJSONString(person, prettyPrint: true)!
    print(content)
    
    objectLabel.text = person.description
    dictLabel.text = dictionary.description
    stringLabel.text = content
  }
}

class Person: CustomStringConvertible, Mappable {

  var name: String!
  var surname: String!
  var ssn: String!
  var weight: Int!
  var height: Int!
  
  var fullName: String {
    return "\(name) \(surname)"
  }
  
  init(name: String!, surname: String!, ssn: String!, weight: Int!, height: Int!) {
    self.name = name
    self.surname = surname
    self.ssn = ssn
    self.weight = weight
    self.height = height
  }
  
  required init?(_ map: Map) {
    //self.init(name: nil, surname: nil, ssn: nil, weight: nil, height: nil)
  }
  
  func mapping(_ map: Map) {
    name <- map["name"]
    surname <- map["surname"]
    ssn <- map["ssn"]
    weight <- map["weight"]
    height <- map["height"]
  }

  var description: String {
    return "<Person: \(fullName)> | Weight: \(weight) | Height: \(height)"
  }
}
