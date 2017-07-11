//
//  HomeViewController.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 27/04/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class HomeViewController: ButtonBarPagerTabStripViewController {
    
    @IBOutlet var scrollView: ButtonBarView!
    
    var isReload = false

    override func viewDidLoad() {
        
        //Change pageTab setting
        self.view.backgroundColor = UIColor.white
        self.settings.style.selectedBarHeight = 2
        self.settings.style.selectedBarBackgroundColor = .white
        self.settings.style.buttonBarItemBackgroundColor = UIColor(red: 130/255.0, green: 18/255.0, blue: 23/255.0, alpha: 1.0)
        self.settings.style.buttonBarBackgroundColor = UIColor(red: 130/255.0, green: 18/255.0, blue: 23/255.0, alpha: 1.0)
        self.settings.style.selectedBarBackgroundColor = .white
        
        self.settings.style.buttonBarHeight = 50

        super.viewDidLoad()

        // Force the UITabbar to be displayed at the bottom of the UIscrollView
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        
    }

    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let child_1 = PageFeedsViewController(style: .plain, itemInfo: IndicatorInfo(title: "My feeds"))
        let child_2 = PagePopularViewController(style: .plain, itemInfo: IndicatorInfo(title: "Popular"))
        let child_3 = PageGamesViewController(style: .plain, itemInfo: IndicatorInfo(title: "Games"))
        
        guard isReload else {
            
            return [child_1, child_2, child_3]
        }
        
        var childViewControllers = [child_1, child_2, child_3]
        
        for (index, _) in childViewControllers.enumerated(){
            
            let nElements = childViewControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index{
                swap(&childViewControllers[index], &childViewControllers[n])
            }
        }
        
        let nItems = 1 + (arc4random() % 8)
        return Array(childViewControllers.prefix(Int(nItems)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
