//
//  BannerContentView.swift
//  ZhihuDaily
//
//  Created by kemchenj on 8/15/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit

class BannerContentView: UIView {

    var imageView = UIImageView()
    var label = UILabel()
    var labelMargin: CGFloat = 8
    
    private var model: ModelBannerCanPresent!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.frame = frame
        imageView.drawLinearGradient(startColor: UIColor.black,
                           endColor: UIColor.clear,
                           startPoint: CGPoint(x: 0,
                                               y: 0),
                           endPoint: CGPoint(x: 0,
                                             y: 1))
        
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        addSubview(imageView)
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureModel(model: ModelBannerCanPresent) {
        self.model = model
        
        imageView.af_setImageWithURL(model.bannerImageURL!)
        
        let height = model.bannerTitle.getHeight(givenWidth: UIScreen.main.bounds.width - labelMargin * 2,
                                                 font: label.font)
        label.frame = CGRect(origin: CGPoint(x: labelMargin,
                                             y: frame.height - height - 37),
                             size: CGSize(width: UIScreen.main.bounds.width - labelMargin * 2,
                                          height: height))
        label.text = model.bannerTitle
    }
}
