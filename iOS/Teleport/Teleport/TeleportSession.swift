//
//  Teleport.swift
//  Teleport
//
//  Created by KaMi on 9/5/18.
//  Copyright © 2018 Nenad VULIC. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol TeleportSessionDelegate: class {
    func dataReceived(_ data: Data)
}

class TeleportSession: NSObject {
    var session: MCSession!
    var peerID: MCPeerID!
    var browser: MCNearbyServiceBrowser!
    weak var delegate: TeleportSessionDelegate?
    
    init(_ delegate: TeleportSessionDelegate) {
        super.init()
        self.delegate = delegate
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: self.peerID)
        self.session.delegate = self
        self.browser = MCNearbyServiceBrowser(peer: self.peerID, serviceType: "teleport")
        self.browser.delegate = self
        self.browser.startBrowsingForPeers()
    }
}

extension TeleportSession: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?){
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID){
        NSLog("lost peerID: \(peerID.displayName)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error){
    }
}

extension TeleportSession: MCSessionDelegate {
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState){

    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID){
        self.delegate?.dataReceived(data)
        //TODO user mediator
        //self.usersContainer?.initialize(with: data)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID){
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress){
        
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: URL, withError error: Error?){
        
    }

}
