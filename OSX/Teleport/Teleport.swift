//
//  Teleport.swift
//  Teleport
//
//  Created by KaMi on 9/5/18.
//  Copyright © 2018 Nenad VULIC. All rights reserved.
//

import Foundation
import Cocoa
import MultipeerConnectivity

protocol TeleportDelegate {
    func teleportPeerStateChange(_ connectedPeerId: MCPeerID, _ state: MCSessionState)
}

class Teleport: NSObject {
    var advertiser: MCNearbyServiceAdvertiser!
    var session: MCSession!
    var peerID: MCPeerID!
    var teleportDelegate: TeleportDelegate?
    
    fileprivate var connectedPeerId: MCPeerID?
    
    init(_ delegate: TeleportDelegate) {
        super.init()
        
        self.peerID = MCPeerID(displayName: "teleport-host")
        self.teleportDelegate = delegate
        self.session = MCSession(peer: self.peerID)
        self.session.delegate = self
        self.advertiser = MCNearbyServiceAdvertiser(peer: self.peerID, discoveryInfo: nil, serviceType: "teleport")
        self.advertiser.delegate = self
        self.advertiser.startAdvertisingPeer()
    }
}

extension Teleport: MCNearbyServiceAdvertiserDelegate{
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }
    
    
    private func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError){
        NSLog("didn't start to advertise, and the error is \(error.debugDescription)")
    }
    
}


extension Teleport: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState){
        self.teleportDelegate?.teleportPeerStateChange(peerID, state)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID){
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID){
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress){
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?){
        
    }
    
}

extension Teleport {
    public func sendCredentialFile(_ data: Data) -> Void {
        do {
            try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
        }
        catch let error {
            NSLog("%@", "Error for sending: \(error)")
        }
    }
    
    public func connectedPeerName() -> String {
        if let connectedPeer = self.connectedPeerId {
            if self.session.connectedPeers.contains(connectedPeer) {
                return connectedPeer.displayName
            }
        }
        return ""
    }
    
    public func isConnected() -> Bool {
        if let connectedPeer = self.connectedPeerId {
            return self.session.connectedPeers.contains(connectedPeer)
        }
        return false
    }
    
    public func disconnectClient() {
        self.connectedPeerId = nil
        self.session.disconnect()
    }
}
