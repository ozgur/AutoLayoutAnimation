//
//  AlamofireSerializeViewController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 10/20/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit
import Alamofire

class AlamofireSerializeViewController: UIViewController {
  
  @IBOutlet fileprivate weak var responseLabel: UILabel!
  @IBOutlet fileprivate weak var activityIndicatorView: UIActivityIndicatorView!

  convenience init() {
    self.init(nibName: "AlamofireSerializeViewController", bundle: nil)
  }

  override func loadView() {
    super.loadView()
    view.backgroundColor = .white
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Alamofire Serializer"
    edgesForExtendedLayout = UIRectEdge()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    responseLabel.text = nil
    activityIndicatorView.startAnimating()
    
    Alamofire.request(.GET, "http://httpbin.org/get", parameters: ["user_id": "1", "page": "2", "view": "as_list"])
      .responseHTTPGetResponse { response in
        self.activityIndicatorView.stopAnimating()
        self.responseLabel.text = response.result.value?.description
    }
  }
}

open class HTTPGetResponse: CustomStringConvertible {
  
  open let args: [String: AnyObject]
  open let headers: [String: AnyObject]
  open let origin: [String]
  open let url: URL

  init(args: [String: AnyObject], headers: [String: AnyObject], origin: [String], url: URL) {
    self.args = args
    self.headers = headers
    self.origin = origin
    self.url = url
  }
  
  convenience init(data: [String: AnyObject]) {
    let args = data["args"] as? [String: AnyObject] ?? [:]
    let headers = data["headers"] as? [String: AnyObject] ?? [:]
    let origin = (data["origin"] as? String)?.components(separatedBy: ",") ?? []
    
    self.init(args: args, headers: headers, origin: origin, url: URL(string: data["url"] as! String)!)
  }
  
  open var description: String {
    let result = NSMutableString()

    result.append("Arguments:\n")

    result.append(args.map({ (key, value) -> String in
      return key + " -> " + String(value)
    }).joined(separator: "\n"))

    result.append("\n\nOrigin:\n")
    result.append(origin.joined(separator: "\n"))

    result.append("\n\nURL:\n")
    result.appendString(url.absoluteString)

    return String(result)
  }
}

extension Request {
  
  fileprivate class func HTTPGetResponseSerializer() -> ResponseSerializer<HTTPGetResponse, NSError> {
  
    return ResponseSerializer(serializeResponse: {
      (request, response, data, error) -> Result<HTTPGetResponse, NSError> in
      
      guard error == nil else {
        return Result.failure(error!)
      }
      
      do {
        let JSON = try JSONSerialization.jsonObject(with: data!, options: [])
        return Result.success(HTTPGetResponse(data: JSON as! [String: AnyObject]))
        
      } catch {
        return .failure(error as NSError)
      }
    })
  }
  
  public func responseHTTPGetResponse(_ completionHandler: (Response<HTTPGetResponse, NSError>) -> Void) -> Self {
    return response(responseSerializer: Request.HTTPGetResponseSerializer(), completionHandler: completionHandler)
  }
}


