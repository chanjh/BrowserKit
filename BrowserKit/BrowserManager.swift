//
//  BrowserManager.swift
//  GCWebContainerDemo
//
//  Created by 陈嘉豪 on 2021/12/18.
//

import Foundation
import ObjectiveC

@objc protocol BrowserManagerObserver: NSObjectProtocol {
    @objc optional func browserManager(_ browserManager: BrowserManager,
                                       didCreate webView: GCWebView?)
    @objc optional func browserManager(_ browserManager: BrowserManager,
                                       didRemove webView: GCWebView?)
}
class BrowserManager: NSObject {
    static let shared = BrowserManager()
    
    private(set) var observers: NSHashTable<BrowserManagerObserver> = NSHashTable(options: .weakMemory)
    
    private(set) var pool: [PDWebView] = [];
    
    var count: Int { return pool.count }
    
    func addObserver(_ observer: BrowserManagerObserver) {
        observers.add(observer)
    }
    
    func removeObserver(_ observer: BrowserManagerObserver) {
        observers.remove(observer)
    }
    
    func makeBrowser(model: WebContainerModelConfig? = nil,
                     ui: WebContainerUIConfig? = nil,
                     for url: URL? = nil) -> PDWebView {
        let makeBrowserAction = url?.scheme == PDURLSchemeHandler.scheme && PDManager.shared.pandoras.contains(where: { $0.id == url?.host })
        if makeBrowserAction {
            return makeBrowserActionBrowser(model: model, ui: ui, pdId: (url?.host)!)
        }
        return makeContentBrowser(model: model, ui: ui)
    }
    
    private func makeContentBrowser(model: WebContainerModelConfig? = nil,
                                    ui: WebContainerUIConfig? = nil) -> PDWebView {
        let webView = PDWebView(frame: .zero, type: .content, model: model, ui: ui)
        webView.identifier = Int(Int64.random(in: 0...9007199254740990))
        print("BrowserManager Create Browser \(webView.identifier ?? 0)")
        pool.append(webView)
        observers.allObjects.forEach { $0.browserManager?(self, didCreate: webView) }
        return webView
    }
    
    private func makeBrowserActionBrowser(model: WebContainerModelConfig? = nil,
                                  ui: WebContainerUIConfig? = nil,
                                  pdId: String) -> PDWebView {
        let webView = PDWebView(frame: .zero, type: .browserAction(pdId), model: model, ui: ui)
        webView.identifier = Int(Int64.random(in: 0...9007199254740990))
        print("BrowserManager Create Browser \(webView.identifier ?? 0)")
        pool.append(webView)
        observers.allObjects.forEach { $0.browserManager?(self, didCreate: webView) }
        return webView
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
    
    func remove(_ webView: PDWebView) {
        pool.removeAll { $0 == webView }
    }
    func remove(_ identifier: Int) {
        pool.removeAll { $0.identifier == identifier }
    }
}
