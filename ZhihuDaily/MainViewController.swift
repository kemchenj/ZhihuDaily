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
                self.tableView.insertSections(IndexSet(integer: self.news.count-1), with: .top)
            }
        }
    }
        
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
        bar?.barTintColor = Theme.mainColor
    }
    
    func configureTableView() {
        tableView.rowHeight = 101
        tableView.estimatedRowHeight = 101
        tableView.contentInset.top = -64
        
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
                
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func configureImageBanner() {
        
        imageBanner.models = news[0].topStories!.map({ (story) -> ModelBannerCanPresent in
            return story as ModelBannerCanPresent
        })
        
        imageBanner.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                action: #selector(tapImageBanner)))
    }
    
    func tapImageBanner(gesture: UITapGestureRecognizer) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "MasterToDetail":
            guard let destinationVC = segue.destination as? DetailViewController,
                let cell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as? StoryCell else { fatalError() }
            
            destinationVC.story = cell.story
            
        default: break
        }
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
        request(newsURL, withMethod: .get).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                do {
                    let news = try News.decode(json: json)
                    self.news.append(news)
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



// Mark: - Table View Delegate/DataSource

// Mark: - Data Source
extension MainViewController {
    
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        
        header?.textLabel?.text = news[section].beautifulDate
        header?.textLabel?.textColor = UIColor.white
        header?.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        let backgroundView = UIView(frame: header!.frame)
        backgroundView.backgroundColor = Theme.mainColor
        
        header?.backgroundView = backgroundView
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "MasterToDetail", sender: nil)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == news.count-1 && indexPath.row == 0 {
            loadPreviousNews()
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navigationBarBackgroundImage!.alpha = navigationBarAlpha
    }
}
