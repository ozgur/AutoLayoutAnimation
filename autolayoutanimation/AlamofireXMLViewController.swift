//
//  AlamofireXMLViewController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 10/19/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit
import Alamofire
import Ono

class AlamofireXMLViewController: UIViewController {
  
  @IBOutlet fileprivate weak var responseLabel: UILabel!
  @IBOutlet fileprivate weak var activityIndicatorView: UIActivityIndicatorView!

  convenience init() {
    self.init(nibName: "AlamofireXMLViewController", bundle: nil)
  }
  
  override func loadView() {
    super.loadView()
    view.backgroundColor = UIColor.white
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Alamofire XML"
    edgesForExtendedLayout = UIRectEdge()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    responseLabel.text = nil
    activityIndicatorView.startAnimating()
    
    Alamofire.request(.GET, "http://httpbin.org/xml").responseXMLDocument { response in
      
      self.activityIndicatorView.stopAnimating()
      
      if response.result.isFailure {
        self.responseLabel.text = response.result.error!.description
      }
      else {
        self.responseLabel.text = response.result.value!.description
      }
    }
  }
}

extension Request {
  fileprivate class func XMLResponseSerializer() -> ResponseSerializer<ONOXMLDocument, NSError> {

    return ResponseSerializer(serializeResponse: { (request, response, data, error) -> Result<ONOXMLDocument, NSError> in
      guard error == nil else {
        return Result.failure(error!)
      }
      guard data != nil else {
        let failure = Alamofire.Error.errorWithCode(
          .dataSerializationFailed,
          failureReason: "Data could not be serialized. Input data was nil."
        )
        return Result.failure(failure)
      }
      do {
        let xmlDocument = try ONOXMLDocument(data: data!)
        return Result.success(xmlDocument)
      } catch {
        return Result.failure(error as NSError)
      }
    })
  }
  
  func responseXMLDocument(_ completionHandler: (Response<ONOXMLDocument, NSError>) -> Void) -> Self {
    return response(responseSerializer: Request.XMLResponseSerializer(), completionHandler: completionHandler)
  }
}
