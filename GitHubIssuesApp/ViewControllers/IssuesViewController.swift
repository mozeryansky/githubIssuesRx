//
//  IssuesViewController.swift
//  GitHubIssuesApp
//
//  Created by Michael Ozeryansky on 9/30/17.
//  Copyright © 2017 Michael Ozeryansky. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class IssuesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UITextField!
    
    let disposeBag = DisposeBag()
    let viewModel = GithubIssueViewModel()
    
    var issues: [GithubIssue] = []
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        
        viewModel.bindSearchText(searchText: searchBar.rx.text.orEmpty.asObservable())
        
        viewModel.issuesSubmit.subscribe { event in
            if let issues = event.element {
                DispatchQueue.main.async {
                    self.issues = issues
                    self.tableView.reloadData()
                }
            }
        }
        .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: - Table
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return issues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        cell.textLabel?.text = issues[indexPath.row].title
        
        return cell
    }
}

