//
//  PandoraDelegateImpl.swift
//  GCWebContainerDemo
//
//  Created by 陈嘉豪 on 2022/4/18.
//

import UIKit

class PandoraDelegateImpl: PandoraDelegate {
    weak var browser: BrowserViewController?
    init(_ browser: BrowserViewController) {
        self.browser = browser
    }
    var runnerDelegate: PandoraRunnerDelegate? { self }
    var tabsManager: IPandoraTabsManager? { self }
}

extension PandoraDelegateImpl: PandoraRunnerDelegate {
    func openURL(_ options: OpenURLOptions) -> GCTabInfo {
        let tab = browser?.didAddUrl(options.url)
        return GCTabInfo(id: "\(tab?.id ?? 0)")
    }

    func removeTab(_ options: GCTabInfo) {
//        TabsManager.shared.remove(options.id)
    }
}

extension PandoraDelegateImpl: IPandoraTabsManager {
    var pool: [PDWebView] { TabsManager.shared.pool }
    
    func addObserver(_ observer: PDTabsEventListerner) {
        TabsManager.shared.addObserver(observer)
    }
    
    func removeObserver(_ observer: PDTabsEventListerner) {
        TabsManager.shared.removeObserver(observer)
    }
    
    func remove(tab identifier: Int){
        TabsManager.shared.remove(identifier)
    }
    
    func tabInfo(in identifier: Int) -> Tab? {
        return nil
    }
    
    func webView(in identifier: Int) -> PDWebView? {
        return TabsManager.shared.browser(for: identifier)
    }
}
