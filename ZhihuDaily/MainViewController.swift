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
    
    var bannerHeight: CGFloat = 200
    
    @IBOutlet weak var imageBanner: BannerView!
    
    var navigationBarBackgroundImage: UIView? {
        return (navigationController?.navigationBar.subviews.first)
    }
    
    var navigationBarAlpha:CGFloat {
        return (tableView.contentOffset.y - 64) / bannerHeight
    }
    
    var topStories = [ModelBannerCanPresent]() {
        didSet {
            imageBanner.models = topStories
        }
    }
    
    var news = [News]() {
        didSet {
            OperationQueue.main.addOperation {
                self.tableView.insertSections(IndexSet(integer: self.news.count - 1), with: .top)
            }
        }
    }
    
    var selectedStory: Story!
    
    var didSelectStory: (Story) -> () = { _ in }
}



// MARK: - View Lifecycle

extension MainViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        setupImageBanner()
        
        loadLatestNews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarBackgroundImage!.alpha = navigationBarAlpha
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "MasterToDetail":
            guard let destinationVC = segue.destination as? DetailViewController else {
                fatalError()
            }
            destinationVC.story = selectedStory
            
        default: break
        }
    }
    
    @IBAction func didSelectRow(sender: AnyObject) {
        print(sender)
        print(sender)
    }
}



// MARK: - Setup

extension MainViewController {
    
    func setupNavigationBar() {
        let bar = navigationController?.navigationBar
        
        bar?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        bar?.shadowImage = UIImage()
        bar?.isTranslucent = false
        bar?.barTintColor = Theme.mainColor
        
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.black.cgColor,
            UIColor.clear.cgColor
        ]
        gradient.startPoint = .zero
        gradient.endPoint = CGPoint(x: 0, y: 1)
        
        bar?.layer.addSublayer(gradient)
    }
    
    func setupTableView() {
        tableView.rowHeight = 101
        tableView.estimatedRowHeight = 101
        tableView.contentInset.top = -64
        tableView.clipsToBounds = false
        tableView.backgroundColor = UIColor.white
        
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupImageBanner() {
        imageBanner.delegate = self
    }
}



// MARK: - Configure

extension MainViewController {
    
    func configureImageBanner() {
        imageBanner.models = topStories.map {
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
    
    // <[]> Implementaion
    func getNews(from newsURL: URL) {
        request(newsURL, withMethod: .get).responseJSON {
            (response) in
            switch response.result {
            case .success(let json):
                do {
                    let news = try News.parse(json: json as AnyObject)
                    self.news.append(news)
                    if self.news.count == 1 {
                        self.updateTopStories()
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
    
    func updateTopStories() {
        topStories = news[0].topStories!.map({ (story) -> ModelBannerCanPresent in
            return story as ModelBannerCanPresent
        })
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
        let cell = tableView.cellForRow(at: indexPath) as! StoryCell
        didSelect(cell.story)
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
        
        if !news.isEmpty {
            imageBanner.offsetY = scrollView.contentOffset.y - 64
        }
    }
}



// MARK: - BannerView Delegate

extension MainViewController: BannerViewDelegate {
    
    func tapBanner(model: ModelBannerCanPresent) {
        guard let story = model as? Story else {
            fatalError()
        }
        
        selectedStory = story
        
        performSegue(withIdentifier: "MasterToDetail", sender: nil)
    }
    
}
