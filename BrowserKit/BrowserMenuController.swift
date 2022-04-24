//
//  BrowserMenuController.swift
//  GCWebContainerDemo
//
//  Created by 陈嘉豪 on 2021/12/18.
//

import UIKit

protocol BrowserMenuControllerDelegate: AnyObject{
    func closeBrowser()
}

class BrowserMenuController: UIViewController {
    let browserId: Int
    weak var delegate: BrowserMenuControllerDelegate?
    init(browserId: Int) {
        self.browserId = browserId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    let menu = [["id":"url", "name":"URL"],
//                ["id":"extension_popup", "name":"Popup Demo"],
                ["id":"extension", "name":"Extension"],
                ["id":"close", "name":"Close Browser"]]
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
    }
}

extension BrowserMenuController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = menu[indexPath.row]["name"]
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let id = menu[indexPath.row]["id"]
        if id == "close" {
            TabsManager.shared.remove(browserId)
            dismiss(animated: true) { [weak self] in
                self?.delegate?.closeBrowser()
            }
        } else if id == "url" {
            let alert = UIAlertController(title: "URL", message: nil, preferredStyle: .alert)
            alert.addTextField { [weak self] textField in
                if let id = self?.browserId {
                    textField.text = TabsManager.shared.browser(for: id)?.url?.absoluteString ?? ""
                }
            }
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { [weak self] _ in
                if let url = URL(string: alert.textFields?.first?.text ?? ""),
                    let id = self?.browserId {
                    _ = TabsManager.shared.browser(for: id )?.load(URLRequest(url: url))
                    self?.dismiss(animated: true, completion: nil)
                }
            }))
            alert.addAction((UIAlertAction(title: "cancel", style: .cancel, handler: nil)))
            present(alert, animated: true, completion: nil)
        } else if id == "extension" {
            let controller = GCExtensionController()
            let nav = UINavigationController(rootViewController: controller)
            present(nav, animated: true, completion: nil)
        }
    }
}
