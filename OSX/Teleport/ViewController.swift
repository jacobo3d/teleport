//
//  ViewController.swift
//  Teleport
//
//  Created by KaMi on 9/5/18.
//  Copyright © 2018 Nenad VULIC. All rights reserved.
//

import Cocoa
import MultipeerConnectivity
class ViewController: NSViewController {

    @IBOutlet weak var teleportView: TeleportView!
    @IBOutlet weak var connectionLabel: NSTextFieldCell!
   
    var teleport: Teleport?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.teleport = Teleport.init(self)
        self.connectionLabel.title = "not connected"
        self.teleportView.teleportViewDelegate = self
        if let deviceName = Host.current().localizedName {
            NSLog(deviceName)
        } else {
            NSLog("teleport-host")
        }
    }
}

extension ViewController : TeleportViewDelegate {
    func teleportCredentials(_ data: Data) {
        self.teleport?.sendCredentialFile(data)
    }
}

extension ViewController : TeleportDelegate {
    func teleportPeerStateChange(_ connectedPeerId: MCPeerID, _ state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .notConnected:
                self.connectionLabel.title = "not connected"
                break
            case .connecting:
                self.connectionLabel.title = "connecting"
                break
            case .connected:

                self.connectionLabel.title = "connected to \(connectedPeerId.displayName)"
                break
            }
        }
    }
}

