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
    private var model: ModelBannerCanPresent!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        drawLinearGradient(startColor: UIColor.black,
                           endColor: UIColor.clear,
                           startPoint: CGPoint(x: 0,
                                               y: 0),
                           endPoint: CGPoint(x: 0,
                                             y: 1))
        
        imageView.frame = frame
        addSubview(imageView)
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureModel(model: ModelBannerCanPresent) {
        self.model = model
        
        imageView.af_setImageWithURL(model.bannerImageURL!)
        label.text = model.bannerTitle
    }
}
