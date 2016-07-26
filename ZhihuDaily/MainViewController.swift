//
//  ViewController.swift
//  Zhihu Daily
//
//  Created by kemchenj on 7/20/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
    let imageBanner = BannerView(frame: CGRect(x: 0,
                                               y: 0,
                                               width: UIScreen.main().bounds.width,
                                               height: 240))
    
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
}



// Mark: - View

extension MainViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureTableView()
        loadLatestNews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarBackgroundImage!.alpha = (tableView.contentOffset.y - 240) / 250
    }
    
    func configureNavigationBar() {
        let bar = navigationController?.navigationBar
        bar?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white()]
        bar?.shadowImage = UIImage()
        bar?.setBackgroundImage(UIImage(), for: .default)
        bar?.isTranslucent = false
        bar?.barTintColor = themeColor
    }
    
    func configureTableView() {
        tableView.tableHeaderView = imageBanner
        
        tableView.rowHeight = 101
        tableView.estimatedRowHeight = 101
        tableView.contentInset.top = -64
        
        //        tableView.frame.origin.y -= 64
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func configureImageBanner() {
        
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
            
            let date = jsonObject["date"] as! String
            var news = News(dateString: date)
            
            // Handle TopStories
            if self.news.count == 0 {
                OperationQueue().addOperation {
                    let topStoryDicts = jsonObject["top_stories"] as! [[String: AnyObject]]
                    var stories = [ModelBannerCanPresent]()
                    for topStoryDict in topStoryDicts {
                        let id = topStoryDict["id"] as! Int
                        let title = topStoryDict["title"] as! String
                        let image = topStoryDict["image"] as! String
                        
                        let story = Story(id: id,
                                          title: title,
                                          thumbNailURL: image)
                        
                        
                        stories.append(story)
                    }
                    
                    self.topStories.append(contentsOf: stories)
                }
            }
            
            // Handle Stories
            let storyDicts = jsonObject["stories"] as! [[String: AnyObject]]
            for storyDict in storyDicts {
                let id = storyDict["id"] as! Int
                let title = storyDict["title"] as! String
                let imageURL = (storyDict["images"] as! [String])[0]
                
                let story = Story(id: id,
                                  title: title,
                                  thumbNailURL: imageURL)
                news.stories.append(story)
            }
            
            self.news.append(news)
            
            DispatchQueue.main.async {
                if self.news.count == 1 {
                    //                    self.configureImageBanner()
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
        performSegue(withIdentifier: "Detail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = tableView.indexPathForSelectedRow
        let story = news[indexPath!.section].stories[indexPath!.row]
        
        let toVC = segue.destinationViewController as! DetailViewController
        toVC.story = story
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == news.count-1 && indexPath.row == 0 {
            loadPreviousNews()
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navigationBarBackgroundImage!.alpha = (scrollView.contentOffset.y - 240) / 250
        print(tableView.contentSize)
    }
}
