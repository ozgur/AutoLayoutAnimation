//
//  PetsViewController.swift
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 3/17/16.
//  Copyright © 2016 Techshed. All rights reserved.
//

import UIKit

class PetsViewController: UIPageViewController, UIPageViewControllerDataSource {
  
  fileprivate let pets = PetCardStore.defaultPets()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    edgesForExtendedLayout = UIRectEdge()

    title = "Custom Animation"
    view.backgroundColor = .black
    dataSource = self
    
    self.setViewControllers([viewControllerAtIndex(0)!], direction: .forward, animated: false, completion: nil)
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    
    if let viewController = viewController as? PetViewController {
      if let index = pets.index(of: viewController.pet) {
        return self.viewControllerAtIndex(index - 1)
      }
    }
    return nil
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    
    if let viewController = viewController as? PetViewController {
      if let index = pets.index(of: viewController.pet) {
        return self.viewControllerAtIndex(index + 1)
      }
    }
    return nil
  }
  
  func presentationCount(for pageViewController: UIPageViewController) -> Int {
    return pets.count
  }
  
  func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    return 0
  }
  
  fileprivate func viewControllerAtIndex(_ index: Int) -> PetViewController? {
    if index >= 0 && index < pets.count {
      let viewController = PetViewController()
      viewController.pet = pets[index]
      return viewController
    }
    return nil
  }
}
