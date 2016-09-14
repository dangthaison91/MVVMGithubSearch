//
//  Extensions.swift
//  GitHubSearch
//
//  Created by Dang Thai Son on 9/14/16.
//  Copyright © 2016 Realm Inc. All rights reserved.
//

import RxCocoa
import RxSwift

/// provide factory method for urls to GitHub's search API
public extension NSURL {
    static func gitHubSearch(query: String, language: String) -> NSURL {
        let query = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        return NSURL(string: "https://api.github.com/search/repositories?q=\(query)+language:\(language)+in:name")!
    }
}

/// Observable emitting the currently selected segment title
extension UISegmentedControl {
    public var rx_selectedTitle: Observable<String?> {
        return rx_value.map(titleForSegmentAtIndex)
    }
}
