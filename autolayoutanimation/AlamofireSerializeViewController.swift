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
  
  @IBOutlet private weak var responseLabel: UILabel!
  @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!

  convenience init() {
    self.init(nibName: "AlamofireSerializeViewController", bundle: nil)
  }

  override func loadView() {
    super.loadView()
    view.backgroundColor = .whiteColor()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Alamofire Serializer"
    edgesForExtendedLayout = .None
  }
  
  override func viewDidAppear(animated: Bool) {
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

public class HTTPGetResponse: CustomStringConvertible {
  
  public let args: [String: AnyObject]
  public let headers: [String: AnyObject]
  public let origin: [String]
  public let url: NSURL

  init(args: [String: AnyObject], headers: [String: AnyObject], origin: [String], url: NSURL) {
    self.args = args
    self.headers = headers
    self.origin = origin
    self.url = url
  }
  
  convenience init(data: [String: AnyObject]) {
    let args = data["args"] as? [String: AnyObject] ?? [:]
    let headers = data["headers"] as? [String: AnyObject] ?? [:]
    let origin = (data["origin"] as? String)?.componentsSeparatedByString(",") ?? []
    
    self.init(args: args, headers: headers, origin: origin, url: NSURL(string: data["url"] as! String)!)
  }
  
  public var description: String {
    let result = NSMutableString()

    result.appendString("Arguments:\n")

    result.appendString(args.map({ (key, value) -> String in
      return key + " -> " + String(value)
    }).joinWithSeparator("\n"))

    result.appendString("\n\nOrigin:\n")
    result.appendString(origin.joinWithSeparator("\n"))

    result.appendString("\n\nURL:\n")
    result.appendString(url.absoluteString)

    return String(result)
  }
}

extension Request {
  
  private class func HTTPGetResponseSerializer() -> ResponseSerializer<HTTPGetResponse, NSError> {
  
    return ResponseSerializer(serializeResponse: {
      (request, response, data, error) -> Result<HTTPGetResponse, NSError> in
      
      guard error == nil else {
        return Result.Failure(error!)
      }
      
      do {
        let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
        return Result.Success(HTTPGetResponse(data: JSON as! [String: AnyObject]))
        
      } catch {
        return .Failure(error as NSError)
      }
    })
  }
  
  public func responseHTTPGetResponse(completionHandler: (Response<HTTPGetResponse, NSError>) -> Void) -> Self {
    return response(responseSerializer: Request.HTTPGetResponseSerializer(), completionHandler: completionHandler)
  }
}


