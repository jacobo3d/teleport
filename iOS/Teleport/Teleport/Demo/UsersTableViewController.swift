//
//  UsersTableViewController.swift
//  Teleport
//
//  Created by KaMi on 9/6/18.
//  Copyright © 2018 Nenad VULIC. All rights reserved.
//

import Foundation
import UIKit

protocol UserDataContainer: class {
    func dataContainer(_ data: Dictionary<String, String>)
}

class UsersTableViewController: UITableViewController {
    var datasource = [Dictionary<String, String>]()
    weak var containerDelegate: UserDataContainer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "close", style: .done, target: self, action: #selector(UsersTableViewController.close))
        Teleport.sharedInstance.addContainerObserver(withType: .user, with: self)
        Teleport.sharedInstance.loadFromCache()
    }
    
    @objc func close(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "user_cell")
        let userData = self.datasource[indexPath.row]
        cell?.textLabel?.text = userData["username"]
        return cell!
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.containerDelegate?.dataContainer(self.datasource[indexPath.row])
        self.close()
    }
}

extension UsersTableViewController: TeleportObserver {
    func didSetup(propertyName: String) {
        print("observer \(propertyName) installed")
    }
    
    func didChange(propertyName: String, oldPropertyValue: [Dictionary<String, String>]?) {
        print("data changed \(propertyName)")
        
    }
    
    func willChange(propertyName: String, newPropertyValue: [Dictionary<String, String>]?) {
        print("data changed \(propertyName)")
        if let freshDatas = newPropertyValue {
            self.datasource = freshDatas
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
