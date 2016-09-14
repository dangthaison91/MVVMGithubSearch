//
//  GithubSearchViewController.swift
//  GitHubSearch
//
//  Created by Dang Thai Son on 9/11/16.
//  Copyright © 2016 Realm Inc. All rights reserved.
//

// For brevity all the example code is included in this single file,
// in your own projects you should spread code and logic into different classes.

import UIKit

import RxSwift
import RxCocoa
import RxDataSources
import RxOptional

import RealmSwift
import RxRealm

protocol GithubSearchViewModelType {
    // Input
    var searchKey: PublishSubject<String> { get }
    var language: PublishSubject<String> { get }
    
    // Output
    var reposSignal: Driver<[RepoSectionModel]> { get }
}


class GithubViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()
    
    convenience init(viewModel: GithubSearchViewModelType) {
        self.init(nibName: nil, bundle: nil)
        
        searchTextField
            .rx_text
            .bindTo(viewModel.searchKey)
            .addDisposableTo(disposeBag)
        
        viewModel
            .reposSignal
            .drive(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
    }
    
    private let dataSource = RxTableViewSectionedReloadDataSource<RepoSectionModel>()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
class GithubSearchViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var query: UITextField!
    @IBOutlet weak var language: UISegmentedControl!
    
    //MARK: - Properties
    private let viewModel: GithubSearchViewModelType = GithubSearchViewModel()
    private let disposeBag = DisposeBag()
    private let dataSource = RxTableViewSectionedReloadDataSource<RepoSectionModel>()
    
    //MARK: - Bind UI
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInput()
        configureOutput()
    }
}

private extension GithubSearchViewController {
    func configureInput() {
        query
            .rx_text
            .bindTo(viewModel.searchKey)
            .addDisposableTo(disposeBag)
        
        language
            .rx_selectedTitle
            .filterNil()
            .bindTo(viewModel.language)
            .addDisposableTo(disposeBag)
    }
    
    func configureOutput() {
        viewModel
            .reposSignal
            .drive(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        
        dataSource.configureCell = { (_, tableView, indexPath, item) in
            let cell = tableView.dequeueReusableCellWithIdentifier("RepoCell")!
            cell.textLabel?.text = item.name
            cell.detailTextLabel?.text = "\(item.starsCount)" + "🌟"
            return cell
        }
    }
}