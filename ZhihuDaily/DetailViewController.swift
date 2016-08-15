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
    
    var imageViewHeight: CGFloat = 200
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var toolBar: UIToolbar!
    
    var navigationBarBackgroundImage: UIView? {
        return (navigationController?.navigationBar.subviews.first)
    }
    
    var imageView: UIImageView!
    
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
        
        setupBanner()
        setupWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarBackgroundImage?.alpha = (webScrollView.contentOffset.y - 64) / imageViewHeight
    }
}



// MARK: - Setup

extension DetailViewController {
    
    private func setupWebView() {
        webView.backgroundColor = UIColor.white
        
        webScrollView.addSubview(imageView)
        webScrollView.clipsToBounds = false
        webScrollView.delegate = self

        webScrollView.contentInset.top = -64
        webScrollView.scrollIndicatorInsets.top = -64
    }
    
    private func setupBanner() {
        imageView = UIImageView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: UIScreen.main.bounds.width,
                                              height: imageViewHeight))
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.drawLinearGradient(startColor: UIColor.black,
                                     endColor: UIColor.clear,
                                     startPoint: CGPoint(x: 0,
                                                         y: 0),
                                     endPoint: CGPoint(x: 0,
                                                       y: 1))
    }
}



// MARK: Web Request

extension DetailViewController {
    
    private func requestContent() {
        request(story.storyURL, withMethod: .get).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                // 验证数据合理性
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
        
        return html
    }
    
}



// MARK: - Scroll View

extension DetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navigationBarBackgroundImage?.alpha = (scrollView.contentOffset.y - 64) / imageViewHeight
        
        imageView.frame.size.height = max(imageViewHeight - (scrollView.contentOffset.y - 64), imageViewHeight)
        imageView.frame.origin.y = min(scrollView.contentOffset.y - 64, 0)
        
        scrollView.layoutIfNeeded()
    }
}
