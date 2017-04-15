//
//  AlamofirePostViewController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 10/19/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit
import Alamofire

class AlamofirePostViewController: UIViewController {
  
  convenience init() {
    self.init(nibName: "AlamofirePostViewController", bundle: nil)
  }

  @IBOutlet fileprivate weak var activityIndicatorView: UIActivityIndicatorView!
  @IBOutlet fileprivate weak var responseLabel: UILabel!
  @IBOutlet fileprivate weak var progressView: UIProgressView!

  fileprivate func url(_ url: String) -> String {
    return "http://httpbin.org" + url
  }
  
  fileprivate var imagePath: URL! {
    return Bundle.main.url(forResource: "image", withExtension: "jpg")
  }
  
  fileprivate let credentials = URLCredential(user: "ozgur", password: "rbrocks", persistence: .forSession)

  override func loadView() {
    super.loadView()
    view.backgroundColor = UIColor.white
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.edgesForExtendedLayout = UIRectEdge()
    
    title = "Alamofire POST"
  }
  
  @IBAction func uploadButtonTapped(_ sender: UIButton) {
    activityIndicatorView.stopAnimating()
    progressView.progress = 0.0
    progressView.isHidden = false
    
    responseLabel.text = "Sending \(imagePath.absoluteString) ..."
    
    Alamofire.upload(.POST, url("/post"), file: imagePath)
      .progress { bytesSent, totalBytesSent, totalBytesExpectedToSend in
      
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        
        DispatchQueue.main.async(execute: {
          self.progressView.setProgress(progress, animated: true)
          self.responseLabel.text = "Sending %\(progress * 100)"
        })
      }
      .response { request, response, data, error -> Void in
        self.responseLabel.text = "Sent image.jpg"
      }
  }
  
  func login(_ userName: String, password: String, completionHandler: ([String: AnyObject]) -> Void) {
    let device = UIDevice().identifierForVendor!
    let parameters = ["login": userName, "password": password, "deviceid": device]

    Alamofire.request(.POST, "http://www.google.com", parameters: parameters).responseJSON {
      response in
      
      if response.result.isSuccess {
        completionHandler(response.result.value as! [String: AnyObject])
      }
      else {
        print("Error: \(response.result.error!.description)")
      }
    }
  }
  
  @IBAction func headersButtonTapped(_ sender: UIButton) {
    progressView.isHidden = true
    activityIndicatorView.startAnimating()
    responseLabel.text = nil
    
    let absoluteURL: URL! = URL(string: url("/headers"))
    var request = NSMutableURLRequest(url: absoluteURL)
    request.httpMethod = "GET"
    request = Alamofire.ParameterEncoding.url.encode(request, parameters: ["foo": "bar"]).0

    Alamofire.request(request).responseJSON { response in

      self.activityIndicatorView.stopAnimating()

      if response.result.isSuccess {
        let result = response.result.value as! [String: [String: String]]
        let headers = result["headers"]!.map { (key, value) -> String in
          return "\(key) -> \(value)"
        }
        self.responseLabel.text = headers.joined(separator: "\n")
      }
      else {
        self.responseLabel.text = response.result.error!.description
      }
    }
  }
  
  @IBAction func basicAuthButtonTapped(_ sender: UIButton) {
    progressView.isHidden = true
    activityIndicatorView.startAnimating()
    responseLabel.text = nil
    
    Alamofire.request(.GET, url("/basic-auth/\(credentials.user!)/\(credentials.password!)"))
      .authenticate(usingCredential: credentials)
      .responseJSON { response in
        
        self.activityIndicatorView.stopAnimating()

        if response.result.isSuccess {
          let result = response.result.value as! [String: AnyObject]
          let headers = result.map { (key, value) -> String in
            return "\(key) -> \(String(value))"
          }
          self.responseLabel.text = headers.joined(separator: "\n")
        }
    }
  }
}
