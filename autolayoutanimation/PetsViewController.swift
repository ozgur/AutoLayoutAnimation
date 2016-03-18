//
//  PetsViewController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 3/17/16.
//  Copyright © 2016 Techshed. All rights reserved.
//

import UIKit

class PetsViewController: UIPageViewController, UIPageViewControllerDataSource {
  
  private let pets = PetCardStore.defaultPets()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    edgesForExtendedLayout = .None

    title = "Custom Animation"
    view.backgroundColor = .blackColor()
    dataSource = self
    
    self.setViewControllers([viewControllerAtIndex(0)!], direction: .Forward, animated: false, completion: nil)
  }
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    
    if let viewController = viewController as? PetViewController {
      if let index = pets.indexOf(viewController.pet) {
        return self.viewControllerAtIndex(index - 1)
      }
    }
    return nil
  }
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    
    if let viewController = viewController as? PetViewController {
      if let index = pets.indexOf(viewController.pet) {
        return self.viewControllerAtIndex(index + 1)
      }
    }
    return nil
  }
  
  func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
    return pets.count
  }
  
  func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
    return 0
  }
  
  private func viewControllerAtIndex(index: Int) -> PetViewController? {
    if index >= 0 && index < pets.count {
      let viewController = PetViewController()
      viewController.pet = pets[index]
      return viewController
    }
    return nil
  }
}
