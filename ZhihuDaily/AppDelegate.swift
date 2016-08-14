//
//  AppDelegate.swift
//  ZhihuDaily
//
//  Created by kemchenj on 7/24/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UINavigationBar.appearance().tintColor = UIColor.white
        
        // 程序启动
        let mainVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
        window?.rootViewController = mainVC
        window?.makeKeyAndVisible()
        
        setupLaunchImage()
        
        return true
    }

}


// MARK: - Setup LaunchImage

extension AppDelegate {
    
    func setupLaunchImage() {
        // 启动页
        if let data = UserDefaults.standard.value(forKey: "LaunchImage") as? Data, let image = UIImage(data: data) {
            
            let splashView = UIImageView(frame: UIScreen.main.bounds)
            // splashView.alpha = 0
            splashView.backgroundColor = UIColor.black
            window?.addSubview(splashView)
            window?.bringSubview(toFront: splashView)
            splashView.image = image
            
            UIView.animate(
                withDuration: 2,
                delay: 0,
                options: [.curveEaseOut],
                animations: {
                    splashView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    splashView.alpha = 1
                },
                completion: { (_) in
                    splashView.removeFromSuperview()
            })
        }
        downloadNewImage()
    }
    
    func downloadNewImage() {
        let url = URL(string: "https://news-at.zhihu.com/api/4/start-image/1080*1776")!
        
        request(url, withMethod: .get).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                guard let imgURLString = (json["img"] as? String)?.replacingOccurrences(of: "http", with: "https"),
                    let imgURL = URL(string: imgURLString) else {
                        fatalError()
                }
                
                request(imgURL, withMethod: .get).responseData(completionHandler: { (response) in
                    switch response.result {
                    case .success(let data):
                        UserDefaults.standard.set(data, forKey: "LaunchImage")
                        
                    case .failure(let error):
                        print(error)
                        fatalError("   ")
                    }
                })
                
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension AppDelegate {
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
