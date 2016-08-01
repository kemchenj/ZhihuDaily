//
//  News.swift
//  Zhihu Daily
//
//  Created by kemchenj on 7/20/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import Foundation
import UIKit



struct News {
    
    var dateString: String
    var stories: [Story]
    var topStories: [Story]?
    
    var date: String {
        let str = dateString as NSString
        let year = str.substring(to: 4)
        let month = (str.substring(from: 4) as NSString).substring(to: 2)
        let day = str.substring(from: 6)
        
        return year + "年" + month + "月" + day + "日"
    }
    
    private init(dateString: String, stories: [Story], topStories: [Story]?) {
        self.dateString = dateString
        self.stories = stories
        self.topStories = topStories
    }
    
    static func decode(json: [String: AnyObject]) throws -> News {
        guard let dateString = json["date"] as? String,
            let storyDicts = json["stories"] as? [[String: AnyObject]]
            else {
                throw NewsDecodeError.wrongData
        }
        
        var topStories: [Story]?
        if let topStoryDicts = json["top_stories"] as? [[String: AnyObject]] {
            topStories = try topStoryDicts.map { (json) -> Story in
                return try Story.decode(json: json)
            }
        }
        
        
        // Handle Stories
        let stories = try storyDicts.map { (json) -> Story in
            return try Story.decode(json: json)
        }
        
        return News(dateString: dateString,
                    stories: stories,
                    topStories: topStories)
    }
}

extension News {
    
    static var latestNewsURL: URL {
        return URL(string: "https://news-at.zhihu.com/api/4/news/latest")!
    }
    
    var previousNewsURL: URL {
        return URL(string: "https://news-at.zhihu.com/api/4/news/before/\(dateString)")!
    }
}

enum NewsDecodeError: ErrorProtocol {
    case wrongData
}
