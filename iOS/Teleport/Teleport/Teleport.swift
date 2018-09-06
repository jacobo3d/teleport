//
//  Teleport.swift
//  Teleport
//
//  Created by KaMi on 9/6/18.
//  Copyright © 2018 Nenad VULIC. All rights reserved.
//

import Foundation

class Teleport: NSObject {
    static let sharedInstance = Teleport()
    private var session: TeleportSession?
    private var cargo = TeleportCargo.init()
    override private init() {
         self.cargo = TeleportCargo.init()
    }
    
    public func loadFromCache() {
        self.cargo.loadCachedContainer(for: .user)
    }
    
    public func initializeSession() {
        self.session = TeleportSession.init(self)
    }
    
    public func addContainerObserver(withType type: ContainerType, with observer: TeleportObserver) {
        self.cargo << ContainerObserver.init(type: type, observer: observer)
    }
}

extension Teleport: TeleportSessionDelegate {
    func dataReceived(_ data: Data) {
        self.cargo.createContainer(from: data)
    }
}
