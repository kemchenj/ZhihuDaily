//
//  ImageBanner.swift
//  ZhihuDaily
//
//  Created by kemchenj on 7/25/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit



// MARK: - 给Model用的协议，符合这一个协议的Model都可以被BannerView展示
protocol BannerDataSource {
    
    var bannerTitle: String { get }
    
    var bannerImageURL: URL? { get }
    var bannerImage: UIImage? { get }
}



// MARK: - 代理
protocol BannerViewDelegate {
    func tapBanner(model: BannerDataSource)
}



class BannerView: UIView {
    
    var delegate: BannerViewDelegate?
    
    var collectionView: UICollectionView!
    var pageControl: UIPageControl!
    
    var currentPage: Int {
        var currentPage: Int
        let realPage = Int(collectionView.contentOffset.x / UIScreen.main.bounds.width + 0.5)
        
        if realPage == 6 {
            currentPage = 0
        } else if realPage == 0 {
            currentPage = 4
        } else {
            currentPage = realPage - 1
        }
        
        return currentPage
    }
    
    var models = [BannerDataSource]() {
        didSet {
            collectionView.contentOffset.x = UIScreen.main.bounds.width
            collectionView.reloadData()
        }
    }
    
    var offsetY: CGFloat = 0 {
        didSet {
            collectionView.visibleCells.forEach { (cell) in
                guard let contentView = cell.contentView.subviews[0] as? BannerContentView else { fatalError()
                }
                
                let imageView = contentView.imageView
                
                imageView.frame.origin.y = min(offsetY, 0)
                imageView.frame.size.height = max(frame.height - offsetY, frame.height)
                
                let label = contentView.label
                
                label.alpha = 1.6 - offsetY / label.frame.height
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCollectionView()
        setupPageControl()
    }
}



// MARK: - Setup

extension BannerView {
    
    func setupCollectionView() {
        // 初始化
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Banner")
        
        // 配置
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = false
        
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
    
    func setupPageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0,
                                                  y: frame.height - 37,
                                                  width: UIScreen.main.bounds.width,
                                                  height: 37))
        pageControl.numberOfPages = 5
        
        addSubview(pageControl)
    }
    
}



// MARK: - Collection View

extension BannerView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: Data Source
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
    
    
    // MARK: Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.tapBanner(model: models[currentPage])
    }
    
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = currentPage
    }
}
