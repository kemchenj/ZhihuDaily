//
//  ViewController.swift
//  Zhihu Daily
//
//  Created by kemchenj on 7/20/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {

    @IBOutlet weak var imageBanner: BannerView!
    var navigationBarBackgroundImage: UIView? {
        return (navigationController?.navigationBar.subviews.first)
    }
    
    var topStories = [ModelBannerCanPresent]() {
        didSet {
            imageBanner.models = self.topStories as [ModelBannerCanPresent]
        }
    }
    
    var news = [News]() {
        didSet {
            print("**** \(Thread.current)")
            print(news)
            OperationQueue.main.addOperation {
                print("****** \(Thread.current)")
                
                self.tableView.insertSections(IndexSet(integer: self.news.count-1), with: .top)
            }
        }
    }
    
    var selectedStory: Story!
    
    var navigationBarAlpha: CGFloat {
        return (tableView.contentOffset.y - 64) / 250
    }
}



// Mark: - View

extension MainViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        tableView.clipsToBounds = false
                
        configureNavigationBar()
        configureTableView()
        loadLatestNews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarBackgroundImage!.alpha = navigationBarAlpha
    }
    
    func configureNavigationBar() {
        let bar = navigationController?.navigationBar
        bar?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        bar?.shadowImage = UIImage()
        bar?.setBackgroundImage(UIImage(), for: .default)
        bar?.isTranslucent = false
        bar?.barTintColor = themeColor
    }
    
    func configureTableView() {
        tableView.rowHeight = 101
        tableView.estimatedRowHeight = 101
        tableView.contentInset.top = -64
                
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func configureImageBanner() {
        imageBanner.models = news[0].topStories!.map({ (story) -> ModelBannerCanPresent in
            return story as ModelBannerCanPresent
        })
        
        imageBanner.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                action: #selector(tapImageBanner)))
        imageBanner.heightAnchor.constraint(equalToConstant: 264)
    }
    
    func tapImageBanner(gesture: UITapGestureRecognizer) {
        
    }
}



// Mark: - Get Data

extension MainViewController: URLSessionTaskDelegate, URLSessionDelegate {
    
    func loadLatestNews() {
        getNews(from: News.latestNewsURL)
    }
    
    func loadPreviousNews() {
        getNews(from: news.last!.previousNewsURL)
    }
    
    private func getNews(from newsURL:URL) {
        // Request
        let request = URLRequest(
            url: newsURL,
            cachePolicy: .reloadRevalidatingCacheData)
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("*** \(error)")
                return
            }
            
            guard let data = data,
                let jsonObject = try? JSONSerialization.jsonObject(
                    with: data,
                    options: .mutableContainers) as! [String: AnyObject] else {
                        print("*** Internet connect failed")
                        return
            }
            
            do {
                let news = try News.decode(json: jsonObject)
                self.news.append(news)
            } catch {
                fatalError("News decode failed")
            }
            
            DispatchQueue.main.async {
                if self.news.count == 1 {
                    self.configureImageBanner()
                }
            }
        }).resume()
    }
}



// Mark: - Table View Delegate/DataSource

// Mark: - Data Source
extension MainViewController {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return news[section].date
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return news.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news[section].stories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Story") as? StoryCell
        
        if cell == nil {
            cell = StoryCell(style: .subtitle, reuseIdentifier: "Story")
        }
        
        cell?.thumbNail.image = nil
        cell?.configure(for: news[indexPath.section].stories[indexPath.row])
        
        return cell!
    }
}

// Mark: - Delegate
extension MainViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedStory = news[indexPath.section].stories[indexPath.row]
        selectedStory.isRead = true
        
        performSegue(withIdentifier: "Detail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {        
        let toVC = segue.destination as! DetailViewController
        toVC.story = selectedStory
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == news.count-1 && indexPath.row == 0 {
            loadPreviousNews()
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navigationBarBackgroundImage!.alpha = navigationBarAlpha
        imageBanner.setScrollOffset(offset: scrollView.contentOffset.y)
    }
}
