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
    var bannerTitle: String { get }
    
    var bannerImageURL: URL? { get }
    var bannerImage: UIImage? { get }
}



class BannerView: UIView {
    private var scrollView: UIScrollView = {
        
        // 加一层渐变的layer
        let layer: CAGradientLayer = {
            let imageSize = CGSize(
                width: UIScreen.main.bounds.width,
                height: 500)
            
            let layer = CAGradientLayer()
            layer.frame = CGRect(origin: CGPoint.zero,
                                 size: imageSize)
            layer.colors = [
                UIColor.black.withAlphaComponent(0.5).cgColor,
                UIColor.clear.cgColor
            ]
            
            layer.startPoint = CGPoint(x: 0.5, y: 0)
            layer.endPoint = CGPoint(x: 0.51, y: 1)
            layer.locations = [0, 1]
            
            return layer
        }()
        
        // 配置ScrollView
        let scrollView = UIScrollView()
        
        scrollView.layer.addSublayer(layer)
        scrollView.clipsToBounds = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isOpaque = true
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = UIColor.black
        
        return scrollView
    }()
    
    private var stackView: UIStackView!
    
    private var pageAmount: Int {
        return models.count
    }
    
    private var banners = [(label: UILabel, imageView: UIImageView)]()
    var models: [ModelBannerCanPresent]! {
        didSet {
            updateBanner()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureScrollView()
        configureStackView()
    }
}



// Mark: - Update UI

extension BannerView {
    
    private func updateBanner() {
        let width = UIScreen.main.bounds.width
        
        stackView.frame.size.width *= CGFloat(pageAmount)
        
        let amount = abs(pageAmount - banners.count)
        if pageAmount > banners.count {
            for _ in 0 ..< amount {
                // 取出模型
                let model = models[banners.count]
                
                // 初始化imageView
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                stackView.addArrangedSubview(imageView)
                
                // 初始化label
                let label = UILabel()
                label.text = model.bannerTitle
                
                label.frame = imageView.frame
                label.frame.origin.y += 30
                
                scrollView.addSubview(label)
                
                banners.append((label, imageView))
            }
        }
        
        scrollView.contentSize = CGSize(
            width: width * CGFloat(pageAmount),
            height: 0)
        
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
                imageView.af_setImageWithURL(model.bannerImageURL!)
            }
        }
    }
}



// Mark: - Configure

extension BannerView {
    
    private func configureScrollView() {
        scrollView.frame = frame
        
        addSubview(scrollView)
    }
    
    private func configureStackView() {
        stackView = UIStackView(frame: frame)
        
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        scrollView.addSubview(stackView)
    }
}

