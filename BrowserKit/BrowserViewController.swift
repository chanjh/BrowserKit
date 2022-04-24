//
//  BrowserViewController.swift
//  GCWebContainerDemo
//
//  Created by 陈嘉豪 on 2022/1/16.
//

import WebKit
import SnapKit

open class BrowserViewController: UIViewController {
    private var browserView: BrowserView
    private var url: URL?
//    private var pdDelegateImpl: PandoraDelegateImpl?
    
    public init(url: URL? = nil) {
        self.url = url
        self.browserView = BrowserView()
        let webView = TabsManager.shared.makeBrowser(model: browserView, ui: browserView, for: url)
        browserView.reload(webView: webView)
        if let url = url {        
            browserView.load(url: url)
        }
        super.init(nibName: nil, bundle: nil)
        let pdImpl = PandoraDelegateImpl(self)
//        self.pdDelegateImpl = pdImpl
        PDManager.shared.setPDDelegate(pdImpl)
        browserView.delegate = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(browserView)
        browserView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        if let url = url {
            browserView.load(url: url)
        }
        TabsManager.shared.addObserver(self)
    }
}

extension BrowserViewController: BrowserViewDelegate, BrowserMenuControllerDelegate, TabsManagerViewControllerDelegate {
    // --- BrowserViewDelegate
    func didClickTabs() {
        let controller = TabsManagerViewController()
        let nav = UINavigationController(rootViewController: controller)
        controller.delegate = self
        present(nav, animated: true, completion: nil)
    }
    
    func didClickMenu() {
        let menu = BrowserMenuController(browserId: (browserView.webView as? PDWebView)!.identifier!)
//        menu.delegate = self
        menu.modalPresentationStyle = .popover
        let pop = menu.popoverPresentationController
        pop?.permittedArrowDirections = .up
        // todo
        pop?.sourceView = navigationController?.navigationBar
        present(menu, animated: true, completion: nil)
    }
    
    func didClickExtension(sender: UIBarButtonItem) {
        let index = sender.tag
        let pandora = PDManager.shared.pandoras[index]
        
        if pandora.popupFilePath != nil {
            let popVC = PDPopUpViewController(pandora)
            popVC.modalPresentationStyle = .popover
            let pop = popVC.popoverPresentationController
            pop?.permittedArrowDirections = .up
            // todo
            pop?.sourceView = navigationController?.navigationBar
            present(popVC, animated: true, completion: nil)
        } else if let bgRunner = PDManager.shared.findBackgroundRunner(pandora) {
            let manifest: PDManifest = bgRunner.pandora.manifest
            let message = manifest.browserAction == nil ? "PAGEACTION": "BROWSERACTION"
            // todo 缺乏参数
            let tabInfo = TabsManager.shared.tabInfo(browserView.webView)
            let paramsStrBeforeFix = tabInfo.toMap().ext.toString()
            let paramsStr = JSServiceUtil.fixUnicodeCtrlCharacters(paramsStrBeforeFix ?? "")
            let onClickedScript = "window.gc.bridge.eventCenter.publish(\"PD_EVENT_\(message)_ONCLICKED\", \(paramsStr));";
            bgRunner.webView?.evaluateJavaScript(onClickedScript, completionHandler: nil)
        }
        
    }
    
    // --- BrowserMenuControllerDelegate
    func closeBrowser() {
        
    }
    // --- TabsManagerViewControllerDelegate
    func didSelectWebView(_ webView: PDWebView) {
        browserView.reload(webView: webView)
    }
    
    func didAddUrl(_ url: URL?) -> Tab? {
        let webView = TabsManager.shared.makeBrowser(model: browserView, ui: browserView, for: url)
        browserView.reload(webView: webView)
        if let url = url {        
            browserView.load(url: url)
        }
        return Tab(id: webView.identifier)
    }
    
//    func didSelectWebView(_ webView: GCWebView, url: URL?) {
//        browserView.removeFromSuperview()
//        self.url = url ?? webView.url
//        self.browserView = BrowserView(webView)
//        browserView.delegate = self
//
//        view.addSubview(browserView)
//        browserView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//        if let url = self.url {
//            browserView.load(url: url)
//        }
//    }
}

extension BrowserViewController: PDTabsEventListerner {
    public func onActivated(tabId: Int) {

    }

    public func onUpdated(tabId: Int, changeInfo: TabChangeInfo) {

    }
    
    public func onRemoved(tabId: Int, removeInfo: TabRemoveInfo) {
        if tabId == browserView.gcWebView?.identifier {
           if let web = TabsManager.shared.browser(at: 0) {
               browserView.reload(webView: web)
           } else {
               let web = TabsManager.shared.makeBrowser(model: browserView, ui: browserView, for: nil)
               browserView.reload(webView: web)
           }
        }
    }
}
