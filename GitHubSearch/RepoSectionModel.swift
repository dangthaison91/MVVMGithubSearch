//
//  RepoSectionModel.swift
//  GitHubSearch
//
//  Created by Dang Thai Son on 9/13/16.
//  Copyright © 2016 Realm Inc. All rights reserved.
//

import Foundation
import RxDataSources

struct RepoCellModel {
    private let repo: Repo
    
    init(repo: Repo) {
        self.repo = repo
    }
}
extension RepoCellModel {
    var name: String { return repo.full_name }
    var language: String? { return repo.language }
    var starsCount: Int { return repo.stargazers_count }
}

struct RepoSectionModel {
    var header: String
    var repos: [Item]
    
    init(header: String, repos: [Item]) {
        self.header = header
        self.repos = repos
    }
}

extension RepoSectionModel: SectionModelType {
    typealias Item = RepoCellModel
    typealias Identity = String
    
    var identity: String { return header }
    var items: [Item] { return repos }
    
    init(original: RepoSectionModel, items: [Item]) {
        self = original
        self.repos = items
    }
}
