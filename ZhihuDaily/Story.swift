//
//  Story.swift
//  Zhihu Daily
//
//  Created by kemchenj on 7/20/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit

enum StoryDecodeError: Error {
    case dataWrong
}

class Story: ModelBannerCanPresent {
    
    var id: Int
    var title: String
    var thumbNailURL: String
    
    var isRead = false

    var storyURL: String {
        return "https://news-at.zhihu.com/api/4/news/\(id)"
    }
    
    var thumbNailURLL: URL {
        return URL(string: thumbNailURL)!
    }

    private init(id: Int, title: String, thumbNailURL: String) {
        self.id = id
        self.title = title
        self.thumbNailURL = thumbNailURL
    }
    
    static func decode(json: [String: AnyObject]) throws -> Story {
        guard let id = json["id"] as? Int,
              let title = json["title"] as? String else {
                throw StoryDecodeError.dataWrong
        }
        
        var thumbNailURL: String
        
        if let url = (json["images"] as? [String])?.first {
            thumbNailURL = url
        } else if let url = json["image"] as? String {
            thumbNailURL = url
        } else {
            throw StoryDecodeError.dataWrong
        }
        
        return Story(
            id: id,
            title: title,
            thumbNailURL: thumbNailURL
        )
    }
}

extension Story {
    var bannerTitle: String {
        return title
    }
    
    var bannerImageURL: URL? {
        return  URL(string: thumbNailURL.replacingOccurrences(of: "http", with: "https"))
    }
    
    var bannerImage: UIImage? {
        return nil
    }
}
