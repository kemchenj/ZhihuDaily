//
//  BannerContentView.swift
//  ZhihuDaily
//
//  Created by kemchenj on 8/15/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit
import Kingfisher


class BannerContentView: UIView {
    
    var imageView = UIImageView()
    var label = UILabel()
    var labelMargin: CGFloat = 8
    
    var model: ModelBannerCanPresent!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupImageView()
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}



// MARK: - Setup

extension BannerContentView {
    
    func setupImageView() {
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.frame = frame
        
        addSubview(imageView)
    }
    
    func setupLabel() {
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        addSubview(label)
    }
    
}



// MARK: - Configure

extension BannerContentView {

    func configureModel(model: ModelBannerCanPresent) {
        self.model = model
        
        let resource = ImageResource(downloadURL: model.bannerImageURL!)
        imageView.kf_setImage(with: resource)
        
        let height = model.bannerTitle.getHeight(givenWidth: UIScreen.main.bounds.width - labelMargin * 2,
                                                 font: label.font)
        label.frame = CGRect(origin: CGPoint(x: labelMargin,
                                             y: frame.height - height - 37),
                             size: CGSize(width: UIScreen.main.bounds.width - labelMargin * 2,
                                          height: height))
        label.text = model.bannerTitle
    }
}
