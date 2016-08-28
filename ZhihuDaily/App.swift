//
//  App.swift
//  ZhihuDaily
//
//  Created by kemchenj on 28/08/2016.
//  Copyright © 2016 kemchenj. All rights reserved.
//

// MARK: - 处理 VC 间跳转逻辑, 定义 VC 的用户交互行为会触发的事件, 解开 VC 间耦合

import UIKit

class App {

    let navigationController: UINavigationController
    
    init(window: UIWindow) {
        navigationController = window.rootViewController as! UINavigationController
        
        // Master
        let masterViewController = navigationController.viewControllers[0] as! MainViewController
        masterViewController.didSelectStory = showStory
    }
    
    func showStory(story: Story) {
        let detailViewController = UIStoryboard.init(name: "Detail", bundle: nil).instantiateInitialViewController() as! DetailViewController
        detailViewController.story = story
        
        navigationController.pushViewController(detailViewController, animated: true)
    }
}
