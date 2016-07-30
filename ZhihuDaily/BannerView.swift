//
//  ImageBanner.swift
//  ZhihuDaily
//
//  Created by kemchenj on 7/25/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit

// 给Model用的协议，符合这一个协议的Model都可以被BannerView展示
protocol ModelBannerCanPresent {
    var bannerTitle: String {get}
    
    var bannerImageURL: URL? {get}
    var bannerImage: UIImage? {get}
}

class BannerView: UIView {
    
    private var scrollView = UIScrollView()
    
    private var pageNumber: Int = 0
    private let pageControll: UIPageControl = {
        let pageControll = UIPageControl()
        pageControll.hidesForSinglePage = true
        return pageControll
    }()
    private var pageAmount: Int {
        return models.count
    }
    
    private var banners = [(label: UILabel, imageView: UIImageView)]()
    var models = [ModelBannerCanPresent]() {
        didSet {
            updateBanner()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = false
        configureScrollView(in: frame)
        
        let bottom = NSLayoutConstraint(item: pageControll,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0)
        let center = NSLayoutConstraint(item: pageControll,
                                        attribute: .centerX,
                                        relatedBy: .equal,
                                        toItem: self,
                                        attribute: .centerX,
                                        multiplier: 1,
                                        constant: 0)
        
        addSubview(pageControll)
        pageControll.addConstraint(bottom)
        pageControll.addConstraint(center)
    }
    
    func setScrollOffset(offset: CGFloat){
        
    }
    
    private func updateBanner() {
        scrollView.contentSize = CGSize(
            width: frame.width * CGFloat(pageAmount),
            height: 0)
        
        let amount = abs(pageAmount - banners.count)
        if pageAmount > banners.count {
            for i in 0 ..< amount {
                let model = models[banners.count]
                
                let label = UILabel()
                label.text = model.bannerTitle
                
                let imageView = UIImageView(
                    frame: CGRect(x: CGFloat(pageAmount - amount + i) * frame.width,
                                  y: 0,
                                  width: self.frame.width,
                                  height: self.frame.height))
                imageView.isOpaque = true
                imageView.contentMode = .scaleAspectFill
                
                print("**** \(imageView.frame)")
                
                scrollView.addSubview(imageView)
                banners.append((label, imageView))
            }
        } else if pageAmount < banners.count {
            for _ in 0 ..< amount {
                banners.last?.label.removeFromSuperview()
                banners.last?.imageView.removeFromSuperview()
            }
        }
        
        updateUI()
    }
    
    private func updateUI() {
        let models = self.models.filter { (model) -> Bool in
            return model != nil
        }
        
        for i in 0 ..< pageAmount {
            let model = models[i]
            let label = banners[i].label
            let imageView = banners[i].imageView
            
            label.text = model.bannerTitle
            
            if let image = model.bannerImage {
                imageView.image = image
            } else if let imageURL = model.bannerImageURL {
                let request = URLRequest(
                    url: imageURL,
                    cachePolicy: .returnCacheDataElseLoad)
                
                URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    guard let data = data,
                        let image = UIImage(data: data) else {
                            print("Image Error")
                            return
                    }
                    
                    OperationQueue.main.addOperation {
                        print("***** \(Thread.current)")
                        imageView.image = image
                    }
                }).resume()
            } else {
                fatalError("One of the bannerImageURL or bannerImage must exist")
            }
        }
        
        pageControll.numberOfPages = pageAmount
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// Mark: - Configure

extension BannerView {
    
    private func configureScrollView(in frame: CGRect) {
        scrollView.frame = frame
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.isOpaque = true
        scrollView.backgroundColor = UIColor.black()
        addSubview(scrollView)
        
        scrollView.isPagingEnabled = true
        addSubview(pageControll)
    }
}



// Mark: - ScrollView Delegate

extension BannerView: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        pageNumber = Int(scrollView.contentOffset.y / scrollView.frame.width + 0.5)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if pageAmount == pageNumber {
            
        }
    }
}
