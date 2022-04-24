//
//  TabsManager.swift
//  GCWebContainerDemo
//
//  Created by 陈嘉豪 on 2022/1/27.
//

import Foundation


class TabsManager {
    static let shared = TabsManager()
    
    public private(set) var pool: [PDWebView] = [];
    
    var count: Int { return pool.count }
    
    private var observers: NSHashTable<PDTabsEventListerner> = NSHashTable(options: .weakMemory)
    
    func addObserver(_ observer: PDTabsEventListerner) {
        observers.add(observer)
    }
    
    func removeObserver(_ observer: PDTabsEventListerner) {
        observers.remove(observer)
    }
    
    func makeBrowser(model: WebContainerModelConfig? = nil,
                     ui: WebContainerUIConfig? = nil,
                     for url: URL?) -> PDWebView {
        let webView = BrowserManager.shared.makeBrowser(model: model, ui: ui, for: url)
        pool.append(webView)
        return webView
    }
    
    func tabInfo(_ webView: GCWebView) -> Tab {
        let tab = Tab(id: webView.identifier)
        tab.id = webView.identifier
        return tab
    }
    
    func title(at index: Int) -> String? {
        return pool[index].url?.relativeString ?? "\(index)"
    }
    
    func browser(at index: Int) -> PDWebView? {
        return pool[index]
    }
    
    func browser(for identifier: Int) -> PDWebView? {
        return pool.first { $0.identifier == identifier }
    }
    
    func remove(_ webView: GCWebView) {
        if let identifier = webView.identifier {
            remove(identifier)
        }
    }
    func remove(_ identifier: Int) {
        pool.removeAll { $0.identifier == identifier }
        observers.allObjects.forEach {
            $0.onRemoved(tabId: identifier, removeInfo: TabRemoveInfo(isWindowClosing: false, windowId: true))
        }
        BrowserManager.shared.remove(identifier)
    }
}
