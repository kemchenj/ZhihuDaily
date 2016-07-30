//
//  Story.swift
//  Zhihu Daily
//
//  Created by kemchenj on 7/20/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit

struct Story: ModelBannerCanPresent {
    
    var id: Int
    var title: String
    var thumbNailURL: String

    var storyURL: String {
        return "https://news-at.zhihu.com/api/4/news/\(id)"
    }
    
    var thumbNailURLL: URL {
        return URL(string: thumbNailURL)!
    }

    init(id: Int, title: String, thumbNailURL: String) {
        self.id = id
        self.title = title
        self.thumbNailURL = thumbNailURL
    }
    
    static func decode(json: AnyObject) -> Story? {
        guard let id = json["id"] as? Int,
              let title = json["title"] as? String,
              let thumbNailURL = (json["images"] as? [String])?.first else {
                return nil
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
