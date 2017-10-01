//
//  GithubAPI.swift
//  GitHubIssuesApp
//
//  Created by Michael Ozeryansky on 9/30/17.
//  Copyright © 2017 Michael Ozeryansky. All rights reserved.
//

import Foundation

import RxSwift

struct GithubAPI {
    
    let baseURL = URL(string: "https://api.github.com/")!
    
    func getIssues(_ repo: String) -> Observable<[GithubIssue]> {
        guard let issuesURL = issuesURL(repo) else {
            print("Invalid url for repo \(repo)")
            return Observable.just([])
        }
        
        return getJSON(issuesURL: issuesURL).map {
            return $0.map { GithubIssue(title: $0["title"] as! String) }
        }
    }
    
    private func getJSON(issuesURL: URL) -> Observable<[[String: Any]]> {
        let request = URLRequest(url: issuesURL)
        let session = URLSession.shared
        
        return Observable.create { observer in
        
            let task = session.dataTask(with: request) { (data, URLResponse, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    
                    guard let jsonData = data else {
                        print("Error getting issues \(error.debugDescription)")
                        return
                    }
                    
                    do {
                        if let parsedData = try JSONSerialization.jsonObject(with: jsonData) as? [[String:Any]] {
                            observer.onNext(parsedData)
                        } else {
                            observer.onNext([])
                        }
                        
                        observer.onCompleted()
                        
                    } catch let error as NSError {
                        observer.onError(error)
                    }
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    private func issuesURL(_ repo: String) -> URL? {
        let path = "repos/\(repo)/issues"
        
        guard let issuesURL = URL(string: path, relativeTo: baseURL) else {
            return nil
        }
        
        return issuesURL
    }
}
