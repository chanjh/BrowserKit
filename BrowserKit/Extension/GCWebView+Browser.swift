//
//  GCWebView+Browser.swift
//  GCWebContainerDemo
//
//  Created by 陈嘉豪 on 2022/1/18.
//

import Foundation

extension GCWebView {
    var browserView: BrowserView? {
        get {
            return Holder._broweserViewProperty
        }
        set(newValue) {
            Holder._broweserViewProperty = newValue
        }
    }
    
    private struct Holder {
        static var _broweserViewProperty: BrowserView?
    }
}
