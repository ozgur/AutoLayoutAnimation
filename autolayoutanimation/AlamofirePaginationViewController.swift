//
//  AlamofirePaginationViewController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 10/19/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit
import Alamofire

class AlamofirePaginationViewController: UIViewController {
  
  @IBOutlet private weak var pageStepper: UIStepper!
  @IBOutlet private weak var pageLabel: UILabel!
  @IBOutlet private weak var responseLabel: UILabel!
  @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!

  convenience init() {
    self.init(nibName: "AlamofirePaginationViewController", bundle: nil)
  }
  
  var currentPage: Int = 0 {
    didSet {
      pageLabel?.text = String(currentPage)
      pageStepper?.value = Double(currentPage)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    edgesForExtendedLayout = .None
    title = "Alamofire Pagination"
    currentPage = 0
  }
  
  @IBAction func pageChanged(sender: UIStepper) {
    currentPage = Int(sender.value)
  }

  @IBAction func submitButtonTapped(sender: UIButton) {
    responseLabel.text = nil
    activityIndicatorView.startAnimating()
    
    Alamofire.request(Paginator(query: "test query", currentPage: currentPage))
      .responseJSON { response in
        self.activityIndicatorView.stopAnimating()
        
        if response.result.isSuccess {
          let result = response.result.value as! [String: AnyObject]

          if let args = result["args"] as? [String: AnyObject] {
            self.responseLabel.text = args.map { key, value -> String in
              return "\(key) -> \(String(value))"
            }.joinWithSeparator("\n")
          }
        }
    }
  }
}

class Paginator: URLRequestConvertible {
  private static let baseURL: NSURL! = NSURL(string: "http://httpbin.org")
  private static let perPage = 50
  
  let query: String
  let currentPage: Int
  
  init(query: String, currentPage: Int) {
    self.query = query
    self.currentPage = currentPage
  }

  var URLRequest: NSMutableURLRequest {
    let request = NSURLRequest(URL: Paginator.baseURL.URLByAppendingPathComponent("/get"))
    let parameters: [String: AnyObject] = [
      "query": query,
      "offset": Paginator.perPage * currentPage,
      "limit": Paginator.perPage
    ]
    return Alamofire.ParameterEncoding.URL.encode(request, parameters: parameters).0
  }
}