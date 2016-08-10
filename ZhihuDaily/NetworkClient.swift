//
//  NetworkClient.swift
//  ZhihuDaily
//
//  Created by kemchenj on 8/8/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit



public typealias NetworkResult = (Data) -> Void
public typealias JSONResult = (AnyObject) -> Void
public typealias ImageResult = (UIImage) -> Void
public typealias ProgressBlock = (Float) -> Void



// Model需要有decode JSON的方法
protocol DecodeableModel {
    static func decode(json: AnyObject) throws -> Self
}



// Error & Exception类型
enum NetworkClientError: String, Error {
    case connectFailed
    case invalidData
    case invalidContent
}



// 网络请求工具类
class NetworkClient: NSObject {
    
    private var urlSession: URLSession
    private var backgroundSession: URLSession!
    
    private var progressHandlers = [URL: ProgressBlock]()
    private var completionHandlers = [URL: ImageResult]()
    
    // 单例, 用private把初始化方法隐藏起来, 保证只有一个实例
    static let shared = NetworkClient()
    private override init() {
        // 初始化Foreground的urlSession
        let configuration = URLSessionConfiguration.default
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        urlSession = URLSession(configuration: configuration,
                                delegate: nil,
                                delegateQueue: queue)
        
        super.init()
        
        // 初始化Background的urlSession
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: "NetworkClientBackground")
        backgroundSession = URLSession(configuration: backgroundConfiguration,
                                       delegate: self,
                                       delegateQueue: nil)
    }
    
}



// MARK: service methods
extension NetworkClient {
    
    public func getData(from url: URL, completion: NetworkResult) throws {
        let request = URLRequest(url: url)
        let task = urlSession.dataTask(with: request) { [unowned self] (data, response, error) in
            if error != nil {
                throw NetworkClientError.connectFailed
            }
            
            guard let data = data else {
                throw NetworkClientError.invalidData
                return
            }
            
            OperationQueue.main.addOperation {
                completion()
            }
        }
        task.resume()
    }
    
    private func getData(from url: URL, asyncCompletion: NetworkResult) throws {
        do{
            try getData(from: url, completion: { (data) in
                OperationQueue().addOperation {
                    asyncCompletion(data)
                }
            })
        } catch {
            throw error
        }
    }
    
    public func getJSON(from url: URL, completion: JSONResult) throws {
        do {
            try getData(from: url, completion: { data in
                OperationQueue().addOperation {
                    self.parseJSON(data, completion: { json in
                        completion(json)
                    })
                }
            })
        } catch {
            
        }
    }
    
    public func getImage(_ url: URL, completion: ImageResult) -> URLSessionDownloadTask {
        let request = URLRequest(url: url)
        let task = urlSession.downloadTask(with: request) {
            (fileUrl, response, error) in
            guard let fileUrl = fileUrl else {
                
            }
            
            // You must move the file or open it for reading before this closure returns or it will be deleted
            if let data = try? Data(contentsOf: fileUrl), let image = UIImage(data: data) {
                OperationQueue.main.addOperation {
                    completion(image, nil)
                }
            } else {
                OperationQueue.main.addOperation {
                    completion(nil, NetworkClientError.invalidData)
                }
            }
        }
        task.resume()
        return task
    }
    
    public func getImageInBackground(_ url: URL, progressBlock: ProgressBlock? = nil, completion: ImageResult?) -> URLSessionDownloadTask {
        
        progressHandlers[url] = progressBlock
        completionHandlers[url] = completion
        let request = URLRequest(url: url)
        let task = backgroundSession.downloadTask(with: request)
        task.resume()
        return task
    }
    
    private func completeProgress(for url: URL) {
        if let progress = progressHandlers[url] {
            progressHandlers[url] = nil
            OperationQueue.main.addOperation {
                progress(1)
            }
        }
    }
}




// Mark: - 代理方法
extension NetworkClient: URLSessionDelegate, URLSessionDownloadDelegate {
    
    // Task完成时, 所有类型的任务都会被调用
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        
        // 错误处理
        if let error = error, let url = task.originalRequest?.url, let completion = completionHandlers[url] {
            completeProgress(for: url)
            completionHandlers[url] = nil
            
            print(error)
            
            OperationQueue.main.addOperation {
                completion(nil, NetworkClientError.connectFailed)
            }
        }
    }
    
    
    // Mark: - Download Task
    // Download Task进行时会持续调用
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        
        if let url = downloadTask.originalRequest?.url, let progress = progressHandlers[url] {
            
            let percentDone = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            OperationQueue.main.addOperation {
                progress(percentDone)
            }
        }
    }
    
    // Download Task完成时
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        
        // You must move the file or open it for reading before this closure returns or it will be deleted
        if let data = try? Data(contentsOf: location),
            let image = UIImage(data: data),
            let request = downloadTask.originalRequest,
            let response = downloadTask.response {
            
            let cachedResponse = CachedURLResponse(response: response, data: data)
            self.urlSession.configuration.urlCache?.storeCachedResponse(cachedResponse, for: request)
            if let url = downloadTask.originalRequest?.url, let completion = completionHandlers[url] {
                completeProgress(for: url)
                completionHandlers[url] = nil
                OperationQueue.main.addOperation {
                    completion(image, nil)
                }
            }
        } else {
            if let url = downloadTask.originalRequest?.url, let completion = completionHandlers[url] {
                completeProgress(for: url)
                completionHandlers[url] = nil
                OperationQueue.main.addOperation {
                    completion(nil, NetworkClientError.invalidData)
                }
            }
        }
    }
    
    // app已经退出, 下载任务完成时会被调用
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let completionHandler = appDelegate.backgroundSessionCompletionHandler {
            appDelegate.backgroundSessionCompletionHandler = nil
            completionHandler()
        }
    }
}



// Mark: - 解析JSON
private extension NetworkClient {
    
    private func parseJSON(_ data: Data, completion: NetworkResult) {
        do {
            let parseResults = try JSONSerialization.jsonObject(with: data, options: [])
            if let dictionary = parseResults as? NSDictionary {
                OperationQueue.main.addOperation {
                    completion(dictionary, nil)
                }
            } else if let array = parseResults as? [NSDictionary] {
                OperationQueue.main.addOperation {
                    completion(array, nil)
                }
            }
        } catch let parseError {
            print(parseError)
            OperationQueue.main.addOperation {
                completion(nil, NetworkClientError.invalidData)
            }
        }
    }
    
}

