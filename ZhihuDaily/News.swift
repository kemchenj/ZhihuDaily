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
    var stories = [Story]()

    var date: String {
        let str = dateString as NSString
        let year = str.substring(to: 4)
        let month = (str.substring(from: 4) as NSString).substring(to: 2)
        let day = str.substring(from: 6)
        
        return year + "年" + month + "月" + day + "日"
    }
    
    init(dateString: String) {
        self.dateString = dateString
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
