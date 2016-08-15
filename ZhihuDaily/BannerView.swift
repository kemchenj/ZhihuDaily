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



// 代理
protocol BannerViewDelegate {
    func tapBanner()
}



class BannerView: UIView {
    
    var delegate: BannerViewDelegate?
    
    private var collectionView: UICollectionView!
    
    private var pageAmount: Int {
        return models.count
    }
    
    private var banners = [(label: UILabel, imageView: UIImageView)]()
    var models = [ModelBannerCanPresent]() {
        didSet {
           collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCollectionView()
    }
}



// MARK: - Setup

extension BannerView {
    
    private func setupCollectionView() {
        // 初始化
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Banner")
        
        // 配置
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.drawLinearGradient(startColor: UIColor.black,
                                          endColor: UIColor.white,
                                          startPoint: CGPoint(x: 0.5,
                                                              y: 0),
                                          endPoint: CGPoint(x: 0.5,
                                                            y: 1))
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // 设置布局
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width,
                                 height: frame.height)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        //
        addSubview(collectionView)
    }
    
}



// MARK: - Collection View

// MARK: - Data Source

extension BannerView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if models.count != 0 {
            return models.count + 2
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Banner", for: indexPath)
        
        var index: Int
        
        if indexPath.row == 6 {
            index = 0
        } else if indexPath.row == 0 {
            index = 4
        } else {
            index = indexPath.row - 1
        }
        
        if !cell.contentView.subviews.isEmpty, let contentView = cell.contentView.subviews[0] as? BannerContentView {
            contentView.configureModel(model: models[index])
        } else {
            let contentView = BannerContentView(frame: CGRect(origin: .zero,
                                                              size: cell.frame.size))
            contentView.configureModel(model: models[index])
            
            cell.contentView.addSubview(contentView)
        }
        
        return cell
    }
    
}

// MARK: - Delegate

extension BannerView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let screenWidth = UIScreen.main.bounds.width
        switch collectionView.contentOffset.x {
        case 0:
            collectionView.contentOffset.x = 5 * screenWidth
            
        case 6 * screenWidth:
            collectionView.contentOffset.x = 1 * screenWidth
            
        default: break
        }
    }
}
