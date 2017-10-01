//
//  GithubIssueViewModel.swift
//  GitHubIssuesApp
//
//  Created by Michael Ozeryansky on 9/30/17.
//  Copyright © 2017 Michael Ozeryansky. All rights reserved.
//

import Foundation

import RxSwift

class GithubIssueViewModel {
    
    let githubAPI = GithubAPI()
    
    let issuesSubmit = PublishSubject<[GithubIssue]>()
    
    func bindSearchText(searchText: Observable<String>) {
        let observable = searchText
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMap { text -> Observable<String> in
                if text.isEmpty{
                    return .just("")
                }
                return .just(text)
            }
        
        _ = observable.bind { searchText in
            self.updateIssues(searchText)
        }
    }
    
    func updateIssues(_ repo: String) {
        _ = githubAPI.getIssues(repo).bind(onNext: { issues in
            self.issuesSubmit.onNext(issues)
        })
    }
}
