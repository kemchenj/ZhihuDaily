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
        let imageView = UIImageView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: UIScreen.main.bounds.width,
                                                  height: 200))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.drawLinearGradient(startColor: UIColor.black.withAlphaComponent(0.5),
                                     endColor: UIColor.clear,
                                     startPoint: CGPoint(x: 0.5,
                                                         y: 0),
                                     endPoint: CGPoint(x: 0.5,
                                                       y: 1))
        
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



// MARK: - View Life Cycle

extension DetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarBackgroundImage?.alpha = (webScrollView.contentOffset.y - 64) / 200
    }
}



// MARK: - Setup

extension DetailViewController {
    
    private func setupNavigationBar() {
        let bar = navigationController?.navigationBar
        bar?.shadowImage = UIImage()
        bar?.setBackgroundImage(UIImage(), for: .default)
        bar?.isTranslucent = false
        navigationBarBackgroundImage!.alpha = 0
    }
    
    private func setupWebView() {
        webView.backgroundColor = UIColor.white
        
        webScrollView.clipsToBounds = false
        webScrollView.addSubview(imageView)
        webScrollView.delegate = self
        
        webScrollView.contentInset.top = -64
        webScrollView.contentInset.bottom = 44
        
        webScrollView.scrollIndicatorInsets.top = -64
        webScrollView.contentInset.bottom = 44
    }
}



// MARK: Web Request

extension DetailViewController {
    
    private func requestContent() {
        request(story.storyURL, withMethod: .get).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                guard let imageURL = json["image"] as? String,
                      let body = json["body"] as? String,
                      let css = json["css"] as? [String] else {
                        return
                }
                
                self.imageView.af_setImageWithURL(URL(string: imageURL.replacingOccurrences(of: "http", with: "https"))!)
                
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
    
    // 拼接HTML
    private func concatHTML(css: [String], body: String) -> String {
        var html = "<html>"
        
        html += "<head>"
        css.forEach { html += "<link rel=\"stylesheet\" href=\($0)>" }
        html += "<style>img{max-width:320px !important;}</style>"
        html += "</head>"
        
        html += "<body>"
        html += body
        html += "</body>"
        
        html += "</html>"
        
        // Body 内的所有图片都换成 https 协议
        html = html.replacingOccurrences(of: "http", with: "https")
        
        return html
    }
    
}



// MARK: - Scroll View

extension DetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navigationBarBackgroundImage?.alpha = (scrollView.contentOffset.y - 64) / 200
        imageView.frame.size.height = max(200 - (scrollView.contentOffset.y - 64), 200)
        imageView.frame.origin.y = min(scrollView.contentOffset.y - 64, 0)
        
        scrollView.layoutIfNeeded()
    }
}
