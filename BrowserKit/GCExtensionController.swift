//
//  GCExtensionController.swift
//  GCWebContainerDemo
//
//  Created by 陈嘉豪 on 2022/1/4.
//

import UIKit
import Tiercel

class GCExtensionController: UIViewController {
    lazy var sessionManager: SessionManager = {
        var configuration = SessionConfiguration()
        configuration.allowsCellularAccess = true
        let manager = SessionManager("default", configuration: configuration)
        return manager
    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Extension"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Download Extension",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(downloadAction))
        view.addSubview(tableView)
    }
}

extension GCExtensionController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PDManager.shared.pandoras.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        let pandora = PDManager.shared.pandoras[indexPath.row]
        cell.textLabel?.text = pandora.manifest.name
        return cell
    }
}

extension GCExtensionController {
    @objc func downloadAction() {
        let alert = UIAlertController(title: "Download Extension", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { [weak self] _ in
            if let url = alert.textFields?.first?.text {
                let task = self?.sessionManager.download(url)
                task?.progress(onMainQueue: true) { (task) in
                    let progress = task.progress.fractionCompleted
                    print("下载中, 进度：\(progress)")
                }.success { (task) in
                    PDFileManager.setupPandora(zipPath: URL(string:  task.filePath))
                    print("下载完成")
                }.failure { (task) in
                    print("下载失败")
                }
            }
        }))
        alert.addAction((UIAlertAction(title: "cancel", style: .cancel, handler: nil)))
        present(alert, animated: true, completion: nil)
    }
}
