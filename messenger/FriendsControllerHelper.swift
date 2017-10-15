//
//  FriendsControllerHelper.swift
//  messenger
//
//  Created by Paul Dong on 15/10/17.
//  Copyright © 2017 Paul Dong. All rights reserved.
//

import UIKit
import CoreData

extension FriendsController {
    
    func clearData(){
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            let context = delegate.persistentContainer.viewContext
            
            do {
                let entityNames = ["Message", "Friend"]
                
                for entityName in entityNames {
                    
                    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
                    
                    let objects: [NSManagedObject] = try context.fetch(fetchRequest)
                    
                    for object in objects {
                        context.delete(object)
                    }
                }
                
                try context.save()
                
            }catch let err {
                print(err)
            }
        }
        
    }
    
    
    func setupData(){
        
        clearData()
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            let context = delegate.persistentContainer.viewContext
            
            let mark = Friend(context: context)
            mark.name = "Mark Zuckerberg"
            mark.profileImageName = "zuckprofile"
            
            let message = Message(context: context)
            message.friend = mark
            message.text = "Hello, my name is Mark, Nice to meet you ..."
            message.date = NSDate()
            mark.addToMessages(message)
            
            //steve
            let steve = Friend(context: context)
            steve.name = "Steve Jobs"
            steve.profileImageName = "steve_profile"
            
            let messageSteve = Message(context: context)
            messageSteve.friend = steve
            messageSteve.text = "Apple creates great ios Devices for the world ..."
            messageSteve.date = NSDate()
            steve.addToMessages(messageSteve)
            
            do {
                try context.save()
            }catch let err {
                print(err)
            }
        }
        loadData()
    }
    
    func loadData(){
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            let context = delegate.persistentContainer.viewContext
            
            let fetchRequest: NSFetchRequest = Message.fetchRequest()
            
            do {
                messages = try context.fetch(fetchRequest) as [Message]
            } catch let err {
                print(err)
            }
        }
    }
}
