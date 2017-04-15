//
//  AlamofireDownloadViewController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 10/19/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

import UIKit
import Alamofire

class AlamofireDownloadViewController: UIViewController {
  
  @IBOutlet weak var responseLabel: UILabel!
  @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
  
  fileprivate func url(_ url: String) -> String {
    return "http://httpbin.org" + url
  }
  
  convenience init() {
    self.init(nibName: "AlamofireDownloadViewController", bundle: nil)
  }
  
  override func loadView() {
    super.loadView()
    view.backgroundColor = UIColor.white
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.edgesForExtendedLayout = UIRectEdge()
    title = "Alamofire Streaming"
  }

  @IBAction func downloadButtonTapped(_ sender: UIButton) {
    responseLabel.text = nil
    activityIndicatorView.startAnimating()
    
    let destinationPath = Alamofire.Request.suggestedDownloadDestination(
      directory: .documentDirectory,
      domain: .userDomainMask
    )

    Alamofire.download(.GET, url("/stream/100"), destination: destinationPath).progress {
      bytesReceived, totalBytesReceived, expectedBytes in
      
      DispatchQueue.main.async {
        self.responseLabel.text = "Read \(totalBytesReceived) bytes."
      }
    }
    .response { request, response, data, error in
      self.activityIndicatorView.stopAnimating()
    }
  }
}
