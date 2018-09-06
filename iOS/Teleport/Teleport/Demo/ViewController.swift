//
//  ViewController.swift
//  Teleport
//
//  Created by KaMi on 9/5/18.
//  Copyright © 2018 Nenad VULIC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }

    @IBAction func showContainer(_ sender: Any) {
        let userTableController: UsersTableViewController = (self.storyboard?.instantiateViewController(withIdentifier: "usersContainer") as? UsersTableViewController)!
        userTableController.containerDelegate = self
        let navigationController = UINavigationController(rootViewController: userTableController)
        self.present(navigationController, animated: true) {
            
        }
    }
}

extension ViewController: UserDataContainer {
    func dataContainer(_ data: Dictionary<String, String>) {
        DispatchQueue.main.async {
            self.usernameTextField.text = data["username"]
            self.passwordTextField.text = data["password"]
        }
    }
    
    
}
