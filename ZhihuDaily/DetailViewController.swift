//
//  DetailViewController.swift
//  Zhihu Daily
//
//  Created by kemchenj on 7/20/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class DetailViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var toolBar: UIToolbar!
    
    var navigationBarBackgroundImage: UIView? {
        return (navigationController?.navigationBar.subviews.first)
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView(
            frame: CGRect(x: 0,
                          y: 0,
                          width: UIScreen.main.bounds.width,
                          height: 200))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        let imageSize = CGSize(width: UIScreen.main.bounds.width,
                               height: 200)
        
        let layer = CAGradientLayer()
        layer.frame = CGRect(origin: CGPoint.zero,
                             size: imageSize)
        layer.colors = [UIColor.black.withAlphaComponent(0.8).cgColor,
                        UIColor.clear.cgColor]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.51, y: 1)
        layer.locations = [0, 1]
        
        imageView.layer.addSublayer(layer)
        
        return imageView
    }()
    
    var webScrollView: UIScrollView {
        guard let scrollView = webView.subviews[0] as? UIScrollView else {
            fatalError("Web View Wrong")
        }
        
        return scrollView
    }
    
    var story: Story! {
        didSet {
            self.navigationItem.title = story?.title
            requestContent()
        }
    }
    
}



// Mark: - View

extension DetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.backgroundColor = UIColor.white
        
        configureNavigationBar()
        configureWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarBackgroundImage?.alpha = (webScrollView.contentOffset.y - 64) / 200
    }
    
    func configureNavigationBar() {
        let bar = navigationController?.navigationBar
        bar?.shadowImage = UIImage()
        bar?.setBackgroundImage(UIImage(), for: .default)
        bar?.isTranslucent = false
        navigationBarBackgroundImage!.alpha = 0
    }
    
    func configureWebView() {
        webScrollView.clipsToBounds = false
        webScrollView.addSubview(imageView)
        webScrollView.delegate = self
        webScrollView.contentInset.top = -64
        webScrollView.contentInset.bottom = 44
    }
}


// Mark: Web Request

extension DetailViewController {
    
    func requestContent() {
        request(story.storyURL, withMethod: .get).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                guard var imageURL = json["image"] as? String,
                    let body = json["body"] as? String,
                    let css = json["css"] as? [String] else {
                        return
                }
                
                imageURL = imageURL.replacingOccurrences(of: "http", with: "https")
                self.imageView.af_setImageWithURL(URL(string: imageURL)!)
                
                let html = self.concatHTML(css: css, body: body)
                OperationQueue.main.addOperation {
                    self.webView.loadHTMLString(html, baseURL: nil)
                }
                
            case .failure(let error):
                // Do some exception handle
                fatalError("\(error)")
            }
        }
        
    }
    
    // 拼接
    func concatHTML(css: [String], body: String) -> String {
        var html = "<html>"
        
        html += "<head>"
        css.forEach { (css) in
            html += "<link rel=\"stylesheet\" href=\(css)>"
        }
        html += "<style>img{max-width:320px !important;}</style>"
        html += "</head>"
        
        html += "<body>"
        html += body
        html += "</body>"
        
        html += "</html>"
        
        // Body 内的所有图片都换成 https 协议
        html.replacingOccurrences(of: "http", with: "https")
        
        return html
    }

}



// Mark: - Scroll View

extension DetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navigationBarBackgroundImage?.alpha = (scrollView.contentOffset.y - 64) / 200
    }
}
