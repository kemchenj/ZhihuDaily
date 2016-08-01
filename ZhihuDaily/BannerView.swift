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
    
    var page: Int = 0
    private let pageControll: UIPageControl = {
        let pageControll = UIPageControl()
        pageControll.hidesForSinglePage = true
        return pageControll
    }()
    private var pageAmount: Int {
        return models.count
    }
    
    private var banners = [(label: UILabel, imageView: UIImageView, heightConstraint: NSLayoutConstraint)]()
    var models: [ModelBannerCanPresent]! {
        didSet {
            updateBanner()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.clipsToBounds = false
        autoresizesSubviews = false
        clipsToBounds = false
        configureScrollView(in: frame)
    }
    
    func setScrollOffset(offset: CGFloat){
        for banner in banners {
            banner.heightConstraint.constant = max(200, 264 - offset)
        }
    }
    
    private func updateBanner() {
        let width = UIScreen.main().bounds.width
        
        scrollView.contentSize = CGSize(
            width: width * CGFloat(pageAmount),
            height: 0)
        scrollView.autoresizesSubviews = false
        
        let amount = abs(pageAmount - banners.count)
        if pageAmount > banners.count {
            for i in 0 ..< amount {
                let model = models[banners.count]
                
                let label = UILabel()
                label.text = model.bannerTitle
                scrollView.addSubview(label)
                
                let imageSize = CGSize(width: UIScreen.main().bounds.width,
                                       height: 500)
                
                let layer = CAGradientLayer()
                layer.frame = CGRect(origin: CGPoint.zero,
                                     size: imageSize)
                layer.colors = [UIColor.black().withAlphaComponent(0.5).cgColor,
                                UIColor.clear().cgColor]
                layer.startPoint = CGPoint(x: 0.5, y: 0)
                layer.endPoint = CGPoint(x: 0.51, y: 1)
                layer.locations = [0, 1]
                
                let imageView = UIImageView()
                imageView.layer.addSublayer(layer)
                imageView.contentMode = .scaleAspectFill
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.clipsToBounds = true
                scrollView.addSubview(imageView)
                
                imageView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: CGFloat(i) * width).isActive = true
                imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
                
                imageView.widthAnchor.constraint(equalToConstant: width).isActive = true
                let heightCon = imageView.heightAnchor.constraint(equalToConstant: 200)
                heightCon.isActive = true
                
                print("**** \(imageView.frame)")
                
                banners.append((label, imageView, heightCon))
            }
            
            layoutIfNeeded()
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
            }
        }
        
        pageControll.numberOfPages = pageAmount
    }
}



// Mark: - Configure

extension BannerView {
    
    private func configureScrollView(in frame: CGRect) {
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.isOpaque = true
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = UIColor.black()
        addSubview(scrollView)
        
        scrollView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        scrollView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        scrollView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        pageControll.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pageControll)
        pageControll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        pageControll.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        layoutIfNeeded()
    }
}



// Mark: - ScrollView Delegate

extension BannerView: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        page = Int(scrollView.contentOffset.x / scrollView.frame.width + 0.5)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControll.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width + 0.5)
    }
}
