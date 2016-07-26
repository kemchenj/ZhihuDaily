//
//  DetailViewController.swift
//  Zhihu Daily
//
//  Created by kemchenj on 7/20/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit
import JavaScriptCore

class DetailViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var toolBar: UIToolbar!
    
    var navigationBarBackgroundImage: UIView? {
        return (navigationController?.navigationBar.subviews.first)
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView(
            frame: CGRect(x: 0,
                          y: -66,
                          width: UIScreen.main().bounds.width,
                          height: 200))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        let imageSize = CGSize(width: UIScreen.main().bounds.width,
                               height: 200)
        
        UIGraphicsBeginImageContext(imageSize)
        defer {
            UIGraphicsEndImageContext()
        }
        
        let layer = CAGradientLayer()
        layer.frame = CGRect(origin: CGPoint.zero,
                             size: imageSize)
        layer.colors = [UIColor.black().withAlphaComponent(0.5).cgColor,
                        UIColor.clear().cgColor]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.51, y: 1)
        layer.locations = [0, 1]
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()!
        
        return imageView
    }()
    
    var webScrollView: UIScrollView {
        guard let scrollView = webView.subviews[0] as? UIScrollView else {
            fatalError("Web View Wrong")
        }
        
        return scrollView
    }
    
    var story: Story? {
        didSet {
            self.navigationItem.title = story?.title
            requestContent()
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .lightContent
    }
}



// Mark: - View

extension DetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webScrollView.clipsToBounds = false
        webScrollView.addSubview(imageView)
        webScrollView.delegate = self
        
        configureNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarBackgroundImage?.alpha = (webScrollView.contentOffset.y - 44) / 200
    }
    
    func configureNavigationBar() {
        let bar = navigationController?.navigationBar
        bar?.shadowImage = UIImage()
        bar?.setBackgroundImage(UIImage(), for: .default)
        bar?.isTranslucent = false
        navigationBarBackgroundImage!.alpha = 0
    }
}


// Mark: Web Request

extension DetailViewController {
    
    func requestContent() {
        let requestURL = URL(string: story!.storyURL)
        
        URLSession.shared.dataTask(with: requestURL!, completionHandler: {(data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
            // 简单数据处理
            guard let data = data,
                let jsonObject = try? JSONSerialization.jsonObject(with: data,
                                                                   options: .mutableContainers),
                let body = jsonObject["body"] as? String,
                let imageURL = jsonObject["image"] as? String,
                let css = jsonObject["css"] as? [String] else {
                    return
            }
            
            if let url = URL(string:imageURL.replacingOccurrences(of: "http", with: "https")){
                self.requestImage(from: url)
            }
            
            var html = "<html>"
            html += "<head>"
            html += "<link rel=\"stylesheet\" href=\(css[0])>"
            html += "<style>img{max-width:320px !important;}</style>"
            html += "</head>"
            html += "<body>"
            html += body
            html += "</body>"
            html += "</html>"
            
            //            html = html.replacingOccurrences(of: "http", with: "https")
            
            DispatchQueue.main.async {
                self.webView.loadHTMLString(html, baseURL: nil)
            }
        }).resume()
    }
    
    func requestImage(from url: URL) {
        let request = URLRequest(
            url: url,
            cachePolicy: .returnCacheDataElseLoad)
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let data = data,
                let image = UIImage(data: data) else {
                    fatalError("Data Wrong")
            }
            
            DispatchQueue.main.async {
                self.imageView.image = image
                UIView.animate(withDuration: 0.33, animations: {
                    self.navigationBarBackgroundImage?.alpha = (self.webScrollView.contentOffset.y - 44) / 200
                })
            }
        }).resume()
    }
}



// Mark: - Scroll View

extension DetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navigationBarBackgroundImage?.alpha = (scrollView.contentOffset.y - 44) / 200
    }
}
