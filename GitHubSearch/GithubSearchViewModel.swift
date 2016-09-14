//
//  GithubSearchViewModel.swift
//  GitHubSearch
//
//  Created by Dang Thai Son on 9/13/16.
//  Copyright © 2016 Realm Inc. All rights reserved.
//

import RxCocoa
import RxSwift
import RxRealm
import RealmSwift

struct GithubSearchViewModel: GithubSearchViewModelType {
    
    // Input
    let searchKey: PublishSubject<String> = PublishSubject<String>()
    let language: PublishSubject<String> = PublishSubject<String>()
    
    // Output
    let reposSignal: Driver<[RepoSectionModel]>
    
    private let disposeBag = DisposeBag()
    
    // Init
    init() {
        // Define Search Query
        let query = Observable
            .combineLatest(searchKey.filter { $0.utf8.count > 2 }, language.asObservable()) { term, language in (term, language) }
            .shareReplay(1)
        
        //call Github, save to Realm
        query
            .throttle(0.3, scheduler: MainScheduler.instance)
            .map(NSURL.gitHubSearch)
            .flatMapLatest { url in return NSURLSession.sharedSession().rx_JSON(url).catchErrorJustReturn([]) }
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .map { json -> [Repo] in
                guard let json = json as? [String: AnyObject],
                    items = json["items"] as? [AnyObject] else { return [] }
                
                return items.map { Repo(value: $0) }
            }
            .subscribeNext { repos in
                let realm = try! Realm()
                try! realm.write {
                    realm.add(repos, update: true)
                }
            }
            .addDisposableTo(disposeBag)
        
        // Output
        let realm = try! Realm()
        reposSignal = query
            .flatMap { term, language -> Observable<[RepoSectionModel]> in
                return realm
                    .objects(Repo).filter("full_name CONTAINS[c] %@ AND language = %@", term, language)
                    .asObservableArray()
                    .map { repos in
                        let repoCellModels = repos.map { RepoCellModel(repo: $0) }
                        return [RepoSectionModel(header: language, repos: repoCellModels)]
                }
            }
            .asDriver(onErrorJustReturn: [])
    }
}