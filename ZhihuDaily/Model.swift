//
//  NetworkClient.swift
//  ZhihuDaily
//
//  Created by kemchenj on 8/8/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String: AnyObject]

enum ParseError: Error {
    case missingAttribute(message: String)
}

// Model需要有decode JSON的方法
protocol JSONParsable {
    static func parse(json: JSONDictionary) throws -> Self
}
