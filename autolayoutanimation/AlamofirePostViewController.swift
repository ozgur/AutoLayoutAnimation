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

  @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var responseLabel: UILabel!
  @IBOutlet private weak var progressView: UIProgressView!

  private func url(url: String) -> String {
    return "http://httpbin.org" + url
  }
  
  private var imagePath: NSURL! {
    return NSBundle.mainBundle().URLForResource("image", withExtension: "jpg")
  }
  
  private let credentials = NSURLCredential(user: "ozgur", password: "rbrocks", persistence: .ForSession)

  override func loadView() {
    super.loadView()
    view.backgroundColor = UIColor.whiteColor()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.edgesForExtendedLayout = .None
    
    title = "Alamofire POST"
  }
  
  @IBAction func uploadButtonTapped(sender: UIButton) {
    activityIndicatorView.stopAnimating()
    progressView.progress = 0.0
    progressView.hidden = false
    
    responseLabel.text = "Sending \(imagePath.absoluteString) ..."
    
    Alamofire.upload(.POST, url("/post"), file: imagePath)
      .progress { bytesSent, totalBytesSent, totalBytesExpectedToSend in
      
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        
        dispatch_async(dispatch_get_main_queue(), {
          self.progressView.setProgress(progress, animated: true)
          self.responseLabel.text = "Sending %\(progress * 100)"
        })
      }
      .response { request, response, data, error -> Void in
        self.responseLabel.text = "Sent image.jpg"
      }
  }
  
  func login(userName: String, password: String, completionHandler: ([String: AnyObject]) -> Void) {
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
  
  @IBAction func headersButtonTapped(sender: UIButton) {
    progressView.hidden = true
    activityIndicatorView.startAnimating()
    responseLabel.text = nil
    
    let absoluteURL: NSURL! = NSURL(string: url("/headers"))
    var request = NSMutableURLRequest(URL: absoluteURL)
    request.HTTPMethod = "GET"
    request = Alamofire.ParameterEncoding.URL.encode(request, parameters: ["foo": "bar"]).0

    Alamofire.request(request).responseJSON { response in

      self.activityIndicatorView.stopAnimating()

      if response.result.isSuccess {
        let result = response.result.value as! [String: [String: String]]
        let headers = result["headers"]!.map { (key, value) -> String in
          return "\(key) -> \(value)"
        }
        self.responseLabel.text = headers.joinWithSeparator("\n")
      }
      else {
        self.responseLabel.text = response.result.error!.description
      }
    }
  }
  
  @IBAction func basicAuthButtonTapped(sender: UIButton) {
    progressView.hidden = true
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
          self.responseLabel.text = headers.joinWithSeparator("\n")
        }
    }
  }
}
