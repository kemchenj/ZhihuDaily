//
//  AppDelegate.swift
//  ZhihuDaily
//
//  Created by kemchenj on 7/24/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit

let themeColor = UIColor(red: 56/255,
                         green: 179/255,
                         blue: 245/255,
                         alpha: 1)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UINavigationBar.appearance().tintColor = UIColor.white
        
        // 程序启动
        let mainVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
        window?.rootViewController = mainVC
        window?.makeKeyAndVisible()
        
        // 启动页
        if let data = UserDefaults.standard.value(forKey: "LaunchImage") as? Data,
            let image = UIImage(data: data) {
            
            let splashView = UIImageView(frame: UIScreen.main.bounds)
            // splashView.alpha = 0
            splashView.backgroundColor = UIColor.black
            window?.addSubview(splashView)
            window?.bringSubview(toFront: splashView)
            splashView.image = image
            
            UIView.animate(withDuration: 3, delay: 0,
                           options: [.curveEaseOut], animations: {
                            splashView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                            splashView.alpha = 1
                }, completion: { (_) in
                    splashView.removeFromSuperview()
            })
        }
        downloadNewImage()
        
        return true
    }
    
    func downloadNewImage() {
        let url = URL(string: "https://news-at.zhihu.com/api/4/start-image/1080*1776")!
        
        NetworkClient.shared.getData(from: url, completion: { json in
            guard let urlString = json["img"] as? String,
                  let url = URL(string: urlString) else {
                    return
            }
            
            NetworkClient.shared.getData(from: url, completion: { data in
                guard let 
                
            })
        })
        
        //        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
        //            if let error = error {
        //                print("******* \(error)")
        //            }
        //
        //            guard let data = data,
        //                let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
        //                let urlString = json["img"] as? String else {
        //                    print("Data Wrong")
        //                    return
        //            }
        //
        //            let request = URLRequest(url: URL(string: urlString)!)
        //
        //            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
        //                if let error = error {
        ////                    fatalError("\(error)")
        //                    return
        //                }
        //
        //                guard let data = data else {
        //                    print("Image Data Error")
        //                    return
        //                }
        //
        //                UserDefaults.standard.set(data, forKey: "LaunchImage")
        //            }).resume()
        //        }).resume()
    }
    
    
    // 处理Background Download Task
    var backgroundSessionCompletionHandler: (() -> Void)?
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
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
