//
//  NetworkClient.swift
//  ZhihuDaily
//
//  Created by kemchenj on 8/8/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import Foundation

enum DecodeError: Error {
    case invalidJSON
    case invalidContent
}

// Model需要有decode JSON的方法
protocol DecodeableModel {
    static func decode(json: AnyObject) throws -> Self
}
