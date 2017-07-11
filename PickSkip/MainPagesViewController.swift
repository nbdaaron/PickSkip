//
//  MainPagesViewController.swift
//  PickSkip
//
//  Created by Aaron Kau on 7/11/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import UIKit

class MainPagesViewController: UIPageViewController {

    var pages = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        
        //Appends the View Controllers from the Constants class
        for id in Constants.mainPagesViews {
            pages.append(storyboard!.instantiateViewController(withIdentifier: id))
        }
        
        //Prepares the first view controller to be displayed.
        setViewControllers([pages.first!], direction: .forward, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MainPagesViewController: UIPageViewControllerDataSource {
    
    //This function determines what view controller to display next
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = pages.index(of: viewController)
        if index == nil || index! + 1 == pages.count {
            return nil
        } else {
            return pages[index!+1]
        }
    }
    
    //This function determines what view controller to display previously
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = pages.index(of: viewController)
        if index == nil || index! == 0 {
            return nil
        } else {
            return pages[index!-1]
        }
    }
}
