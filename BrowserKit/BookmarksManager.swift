//
//  BookmarksManager.swift
//  GCWebContainerDemo
//
//  Created by 陈嘉豪 on 2021/12/18.
//

import Foundation

class BookmarksManager {
    static let shared = BookmarksManager()
    let archiveKey = "BrowserKit_Bookmark_key"
    private(set) var bookmarks: [Bookmark]
    
    init() {
        if let list = UserDefaults.standard.array(forKey: archiveKey) as? [[String: String]] {
            bookmarks = list.compactMap {
                guard let url = $0["url"] else { return nil }
                return Bookmark(url: url, title: $0["title"])
            }
        } else {
            bookmarks = []
        }
    }
    
    func save(url: String, title: String?) {
        let mark = Bookmark(url: url, title: title)
        bookmarks.append(mark)
        archive(mark)
    }
    
    private func archive(_ bookmark: Bookmark) {
        var list: [[String: String]] = UserDefaults.standard.array(forKey: archiveKey) as? [[String: String]] ?? []
        list.append(["url": bookmark.url, "title": bookmark.title ?? ""])
        UserDefaults.standard.set(list, forKey: archiveKey)
    }
}

struct Bookmark {
    let url: String
    let title: String?
}
