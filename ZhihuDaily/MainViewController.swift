//
//  ViewController.swift
//  Zhihu Daily
//
//  Created by kemchenj on 7/20/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit
import Alamofire



class MainViewController: UITableViewController {
    
    @IBOutlet weak var imageBanner: BannerView!
    var navigationBarBackgroundImage: UIView? {
        return (navigationController?.navigationBar.subviews.first)
    }
    
    var topStories: [ModelBannerCanPresent] {
        set {
            imageBanner.models = topStories
        }
        get {
            return imageBanner.models
        }
    }
    
    var news = [News]() {
        didSet {
            OperationQueue.main.addOperation {
                self.tableView.insertSections(IndexSet(integer: self.news.count - 1), with: .top)
            }
        }
    }
    
    var navigationBarAlpha:CGFloat {
        return (tableView.contentOffset.y - 64) / 250
    }
}



// MARK: - View Lifecycle

extension MainViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        
        loadLatestNews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarBackgroundImage!.alpha = navigationBarAlpha
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "MasterToDetail":
            guard let destinationVC = segue.destination as? DetailViewController,
                let cell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as? StoryCell else {
                    fatalError()
            }
            
            destinationVC.story = cell.story
            
        default: break
        }
    }
}



// MARK: - Setup

extension MainViewController {
    
    private func setupNavigationBar() {
        let bar = navigationController?.navigationBar
        
        bar?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        bar?.shadowImage = UIImage()
        bar?.setBackgroundImage(UIImage(), for: .default)
        bar?.isTranslucent = false
        bar?.barTintColor = Theme.mainColor
    }
    
    private func setupTableView() {
        tableView.rowHeight = 101
        tableView.estimatedRowHeight = 101
        tableView.contentInset.top = -64
        tableView.clipsToBounds = false
        tableView.backgroundColor = UIColor.white
        
        tableView.tableHeaderView?.frame = CGRect(origin: .zero,
                                                  size: CGSize(width: UIScreen.main.bounds.width,
                                                               height: 264))
        tableView.layoutSubviews()
//        tableView.reloadData()
        
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configureImageBanner() {
        imageBanner.models = news[0].topStories!.map {
            (story) -> ModelBannerCanPresent in
            return story as ModelBannerCanPresent
        }
    }
    
}



// MARK: - Get Data

extension MainViewController: URLSessionTaskDelegate, URLSessionDelegate {
    
    func loadLatestNews() {
        getNews(from: News.latestNewsURL)
    }
    
    func loadPreviousNews() {
        getNews(from: news.last!.previousNewsURL)
    }
    
    // <[Private]> Implementaion
    private func getNews(from newsURL: URL) {
        request(newsURL, withMethod: .get).responseJSON {
            (response) in
            switch response.result {
            case .success(let json):
                do {
                    let news = try News.decode(json: json)
                    self.news.append(news)
                    if self.news.count == 1 {
                        self.configureImageBanner()
                    }
                } catch {
                    fatalError("JSON Data Error")
                }
                
            case .failure(let error):
                // do some thing here
                print(error)
            }
        }
    }
}



// MARK: - Table View Delegate/DataSource

// MARK: - Data Source

extension MainViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return news.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news[section].stories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Story") as? StoryCell
        
        cell?.thumbNail.image = nil
        cell?.configure(for: news[indexPath.section].stories[indexPath.row])
        
        return cell!
    }
}

// MARK: - Delegate

extension MainViewController {
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        
        header?.textLabel?.text = news[section].beautifulDate
        header?.textLabel?.textColor = UIColor.white
        header?.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        header?.layer.backgroundColor = Theme.mainColor.cgColor
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 {
            return 40
        } else {
            return 0
        }
    }
    
    // Row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "MasterToDetail", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 提前加载 News
        if indexPath.section == news.count - 1 && indexPath.row == 0 {
            loadPreviousNews()
        }
        
        // 动态修改
        OperationQueue().addOperation {
            let displaySection = tableView.indexPathsForVisibleRows?.reduce(Int.max, {
                (partialResult, indexPath) -> Int in
                return min(partialResult, indexPath.section)
            })
            
            if displaySection == 0 {
                OperationQueue.main.addOperation {
                    self.navigationItem.title = "今日热文"
                }
            } else {
                OperationQueue.main.addOperation {
                    self.navigationItem.title = self.news[displaySection!].beautifulDate
                }
            }
        }
    }
    
    // Scroll
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navigationBarBackgroundImage!.alpha = navigationBarAlpha
    }
    
}
