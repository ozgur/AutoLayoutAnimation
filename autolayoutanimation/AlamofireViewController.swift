//
//  AlamofireViewController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 10/19/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit
import Alamofire

class AlamofireViewController: UIViewController {

  convenience init() {
    self.init(nibName: "AlamofireViewController", bundle: nil)
  }

  @IBOutlet fileprivate weak var responseLabel: UILabel!
  @IBOutlet fileprivate weak var activityIndicatorView: UIActivityIndicatorView!
  
  fileprivate func url(_ url: String) -> String {
    return "http://httpbin.org" + url
  }

  override func loadView() {
    super.loadView()
    view.backgroundColor = UIColor.white
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.edgesForExtendedLayout = UIRectEdge()

    title = "Alamofire GET"
  }
  
  @IBAction func IPButtonTapped(_ sender: UIButton) {
    responseLabel.text = nil
    activityIndicatorView.startAnimating()
    
    Alamofire.request(.GET, url("/ip"), parameters: ["foo": "bar"])
      .response { (request, response, data, error) -> Void in
        debugPrint(request)
        debugPrint(response)
        debugPrint("Data: \(data)")
        debugPrint(error)
      }
      .responseData { response -> Void in
        debugPrint("ResponseData: \(response.result.value)")
      }
      .responseJSON(options: []) { response -> Void in
        self.activityIndicatorView.stopAnimating()
        
        switch response.result {
        case .success(let value):
          print(value)
        case .failure(let error):
          print(error.localizedDescription)
        }
        let result = response.result.value as! [String: String]
        self.responseLabel.text = result["origin"]!
    }
  }
  
  @IBAction func userAgentButtonTapped(_ sender: UIButton) {
    responseLabel.text = nil
    activityIndicatorView.startAnimating()

    Alamofire.Manager.sharedInstance.request(.GET, url("/user-agent")).responseJSON {
      response in
      self.activityIndicatorView.stopAnimating()
      
      if response.result.isSuccess {
        let result = response.result.value as! [String: String]
        self.responseLabel.text = result["user-agent"]
      }
      else {
        self.responseLabel.text = response.result.error!.description
      }
    }
  }
  
  @IBAction func cookiesButtonTapped(_ sender: UIButton) {
    responseLabel.text = nil
    activityIndicatorView.startAnimating()
    
    Alamofire.request(.GET, url("/cookies/set"), parameters: ["foo": "bar", "sessionid": "test"])
      .responseJSON { response in
        self.activityIndicatorView.stopAnimating()
        
        let result = response.result.value as! [String: [String: String]]
        let cookies = result["cookies"]!.map({ (k, v) -> String in
          return "\(k) -> \(v)"
        })
        self.responseLabel.text = cookies.joined(separator: "\n")
    }
  }
  
}
