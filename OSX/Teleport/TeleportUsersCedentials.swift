//
//  TeleportUsersCedentials.swift
//  Teleport
//
//  Created by KaMi on 9/5/18.
//  Copyright © 2018 Nenad VULIC. All rights reserved.
//

import Foundation

class TeleportUsersCedentials: NSObject {
    public func checkCredentials(_ path: URL) -> Data? {
        do {
            let data = try Data(contentsOf: path, options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let users = jsonResult["users"] as? [Any] {
                // do stuff
                return data
            }
        } catch {
            return nil
        }
        return nil
    }
}
