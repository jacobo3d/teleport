//
//  TeleportParser.swift
//  Teleport
//
//  Created by KaMi on 9/6/18.
//  Copyright © 2018 Nenad VULIC. All rights reserved.
//

import Foundation

protocol TeleportObserver : class {
    func willChange(propertyName: String, newPropertyValue: [Dictionary<String, String>]?)
    func didChange(propertyName: String, oldPropertyValue: [Dictionary<String, String>]?)
    func didSetup(propertyName: String)
}

protocol Container {
    func name() -> String
    func datas() -> [Any]?
    init(jsonData data: Data, andObserver observer: TeleportObserver?)
}

enum ContainerType: String {
    case user = "user"
}

class UserCredential: Container {
    
    weak var observer: TeleportObserver?
    
    fileprivate var users: [Dictionary<String, String>]? {
         willSet(newValue) {
            observer?.willChange(propertyName:ContainerType.user.rawValue , newPropertyValue: newValue)
        }
        didSet {
            observer?.didChange(propertyName: ContainerType.user.rawValue, oldPropertyValue: oldValue)
        }
    }
   
    required init(jsonData data: Data, andObserver observer: TeleportObserver?) {
        self.observer = observer

        do {
            let documentsPath = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentsPath.appendingPathComponent(ContainerType.user.rawValue)
            try data.write(to: fileURL)
        } catch let error as NSError {
            print(error)
            abort()
        }
        self.getUsers(from: data)
    }
    
    func name() -> String {
        return ContainerType.user.rawValue
    }
    
    func datas() -> [Any]? {
        return users
    }
}

extension UserCredential {
    fileprivate func getUsers(from data: Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let jsonResult = jsonResult as? Dictionary<String, AnyObject>,
                let users = jsonResult["users"] as? [Dictionary<String, String>] {
                self.users = users
            }
        } catch let error as NSError {
            print(error)
        }
    }
}

enum ContainerFactory {
    static func container(for type: ContainerType, withData data: Data, andObserver observer: TeleportObserver?) -> Container? {
        let container = UserCredential.init(jsonData: data, andObserver: observer)
        return container
    }
}

struct ContainerObserver {
    public var type: ContainerType?
    public var observer: TeleportObserver?
}

final class TeleportCargo: NSObject {
    private var containers = Dictionary<String, Container>()
    private var observers = Dictionary<ContainerType, TeleportObserver>()
    
    override init() {
        super.init()
    }
    
    public func loadCachedContainer(for type :ContainerType){
        do {
            let documentsPath = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentsPath.appendingPathComponent(type.rawValue)
            let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let jsonResult = jsonResult as? Dictionary<String, AnyObject>,
                let containerType = jsonResult["container_type"] as? String {
                if containerType == type.rawValue {
                    self.createContainer(from: data)
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    public func createContainer(from data: Data) {
        do{
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let jsonResult = jsonResult as? Dictionary<String, AnyObject>,
                let containerType = jsonResult["container_type"] as? String {
                switch containerType {
                    case ContainerType.user.rawValue:
                        if let userContainer = ContainerFactory.container(for: .user, withData: data, andObserver: self.observers[ContainerType.user]) {
                            print("container updated \(userContainer.name())")
                        }
                        break
                default:
                    print("container \(containerType) not found")
                }
            }
        }catch{
            print("container structure wrong")
        }
    }
    
    static func <<(left: TeleportCargo, right: ContainerObserver) {
        guard let observerType = right.type else {
            print("container type not defined")
            return
        }
        guard let observer = right.observer else {
            print("container not defined")
            return
        }
        var alreadySetup: Bool = false
        if left.observers[observerType] == nil {
           alreadySetup = false
        } else {
            alreadySetup = true
        }
        left.observers[observerType] = observer
        if !alreadySetup {
            observer.didSetup(propertyName: observerType.rawValue)
        }
    }
}
