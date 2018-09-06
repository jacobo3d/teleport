//
//  TeleportView.swift
//  Teleport
//
//  Created by KaMi on 9/5/18.
//  Copyright © 2018 Nenad VULIC. All rights reserved.
//

import Cocoa

protocol TeleportViewDelegate {
    func teleportCredentials(_ data: Data)
}

class TeleportView: NSView {
    public var teleportViewDelegate: TeleportViewDelegate?
    var userCredentials: TeleportUsersCedentials?
    
    override func awakeFromNib() {
        setup()
    }
        
    func setup() {
        registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: kUTTypeJSON as String),
                                 NSPasteboard.PasteboardType(rawValue: kUTTypeItem as String)])
        self.userCredentials = TeleportUsersCedentials.init()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if isReceivingDrag {
            
        }
    }
    
    override func hitTest(_ aPoint: NSPoint) -> NSView? {
        return nil
    }
    
    func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        var canAccept = false
        
        let pasteBoard = draggingInfo.draggingPasteboard()
        
        if pasteBoard.canReadObject(forClasses: [NSURL.self], options: nil) {
            canAccept = true
        }
     
        return canAccept
        
    }
    
    var isReceivingDrag = false {
        didSet {
            needsDisplay = true
        }
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let allow = shouldAllowDrag(sender)
        isReceivingDrag = allow
        return allow ? .copy : NSDragOperation()
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let allow = shouldAllowDrag(sender)
        return allow
    }
    
    
    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
        isReceivingDrag = false
        let pasteBoard = draggingInfo.draggingPasteboard()
    
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], urls.count > 0 {
            if let data = self.userCredentials?.checkCredentials(urls.first!) {
                self.teleportViewDelegate?.teleportCredentials(data)
            }
            return true
        }
        
        return false
    }
}
