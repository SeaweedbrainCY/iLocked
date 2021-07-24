//
//  TutorialControllerView.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 16/07/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit

class TutorialControllerView: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    
    var index = 0
    var identifiers: NSArray = ["tuto1", "tuto2", "tuto3"]
    
    var pageControl = UIPageControl()
    weak var tutorialDelegate: TutorialPageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        configurePageControl()
        
        let startingViewController = self.viewControllerAtIndex(index: self.index)
        let viewControllers: NSArray = [startingViewController!]
        self.setViewControllers(viewControllers as? [UIViewController], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        tutorialDelegate?.tutorialPageViewController(tutorialPageViewController: self,
                    didUpdatePageCount: identifiers.count)
    }
    
    func configurePageControl() {
            pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
            self.pageControl.numberOfPages = identifiers.count
            self.pageControl.currentPage = 0
            self.pageControl.tintColor = UIColor.lightGray
            self.pageControl.pageIndicatorTintColor = UIColor.white
            self.pageControl.currentPageIndicatorTintColor = UIColor.lightGray
            self.view.addSubview(pageControl)
        }
    
    func viewControllerAtIndex(index: Int) -> UIViewController! {
        print("index = \(index)")
            //first view controller = firstViewControllers navigation controller
        if index <= 2 && index >= 0 {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tuto\(index+1)")
        }
        return nil
        }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        let identifier = viewController.restorationIdentifier
        print("Next")
        print("Identifier = \(String(describing: identifier))")
        
        let index = self.identifiers.index(of: identifier!)
        print("Index = \(index)")
        //if the index is the end of the array, return nil since we dont want a view controller after the last one
        if index == identifiers.count - 1 {
 
            return nil
        }

        //increment the index to get the viewController after the current index
        self.index = index + 1
        
        return self.viewControllerAtIndex(index: self.index)
        }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

            let identifier = viewController.restorationIdentifier
        print("Back")
        print("Identifier = \(String(describing: identifier))")
        print("Index = \(self.index)")
        let index = self.identifiers.index(of: identifier!)

            //if the index is 0, return nil since we dont want a view controller before the first one
            if index == 0 {

                return nil //return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tuto3")
            }

            //decrement the index to get the viewController before the current one
            self.index = index - 1
            return self.viewControllerAtIndex(index: self.index)
        }


        func presentationCountForPageViewController(pageViewController: UIPageViewController!) -> Int {
            return self.identifiers.count
        }

        func presentationIndexForPageViewController(pageViewController: UIPageViewController!) -> Int {
            return 0
        }
    
    // MARK: Delegate functions
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            let pageContentViewController = pageViewController.viewControllers![0]
            //let container = TutorialPageControllerContainer()
            //container.updatePageControl(page: identifiers.index(of: pageContentViewController))
            delegate?.updatePageControl(page: identifiers.index(of: pageContentViewController))
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToContainerViewSegueID" {
            if let containerVC = segue.destination as? TutorialPageControllerContainer {
                containerVC.delegate = self
            }
        }
    }

}
extension TutorialControllerView: UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool) {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.indexOf(firstViewController) {
            tutorialDelegate?.tutorialPageViewController(tutorialPageViewController: self,
                    didUpdatePageIndex: index)
        }
    }
    
}

protocol TutorialPageViewControllerDelegate: AnyObject {
    
    /**
     Called when the number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func tutorialPageViewController(tutorialPageViewController: TutorialControllerView,
        didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func tutorialPageViewController(tutorialPageViewController: TutorialControllerView,
        didUpdatePageIndex index: Int)
    
}
