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
//            //mark
//            let mark = Friend(context: context)
//            mark.name = "Mark Zuckerberg"
//            mark.profileImageName = "zuckprofile"
//            
//            var text = "Hello, my name is Mark, Nice to meet you ..."
//            FriendsController.createMessage(withText: text, friend: mark, minutesAgo: 2, context: context)
            
            //steve
            createSteveMessageWith(context: context)
            
            //donald
            let donald = Friend(context: context)
            donald.name = "Donald Trump"
            donald.profileImageName = "donald_trump_profile"
            var text = "You are fired"
            FriendsController.createMessage(withText: text, friend: donald, minutesAgo: 60 * 24, context: context)
            
            //gandhi
            let gandhi = Friend(context: context)
            gandhi.name = "Mahatma Gandhi"
            gandhi.profileImageName = "gandhi"
            text = "Love, Peace, and Joy"
            FriendsController.createMessage(withText: text, friend: gandhi, minutesAgo: 7 * 60 * 24, context: context)
            
            //hillary
            let hillary = Friend(context: context)
            hillary.name = "Hillary Clinton"
            hillary.profileImageName = "hillary_profile"
            text = "Please vote for me, you did for Billy!"
            FriendsController.createMessage(withText: text, friend: hillary, minutesAgo: 8 * 60 * 24, context: context)
            
            do {
                try context.save()
            }catch let err {
                print(err)
            }
        }
        
        
//        loadData()
    }
    
    private func createSteveMessageWith(context: NSManagedObjectContext) {
        //steve
        let steve = Friend(context: context)
        steve.name = "Steve Jobs"
        steve.profileImageName = "steve_profile"
        FriendsController.createMessage(withText: "I am using Apple devices as much as possible ...", friend: steve, minutesAgo: 4, context: context)
        FriendsController.createMessage(withText: "Apple creates great ios Devices for the world ...", friend: steve, minutesAgo: 3, context: context)
        FriendsController.createMessage(withText: "Are you interested in buying an Apple device? We have a wide variety of Apple devices that will suit your needs. Please make your purchase with us.", friend: steve, minutesAgo: 2, context: context)
        //response
        FriendsController.createMessage(withText: "Yes, totally looking to buy an iPhone 7.", friend: steve, minutesAgo: 1, context: context, isSender: true)
        
        FriendsController.createMessage(withText: "Totally understand that you want the new iPhone 7, but you'll have to wait until September for the new release. Sorry but that's just how Apple likes to do things", friend: steve, minutesAgo: 0, context: context)
        
        FriendsController.createMessage(withText: "Absolutely, I'll just use my gigantic iPhone 6 Plus until then!!!", friend: steve, minutesAgo: 0, context: context, isSender: true)
        
        FriendsController.createMessage(withText: "Ok, cool", friend: steve, minutesAgo: 0, context: context)
        
        FriendsController.createMessage(withText: "Totally understand that you want the new iPhone 7, but you'll have to wait until September for the new release. Sorry but that's just how Apple likes to do things", friend: steve, minutesAgo: 0, context: context)
        
        FriendsController.createMessage(withText: "Absolutely, I'll just use my gigantic iPhone 6 Plus until then!!!", friend: steve, minutesAgo: 0, context: context, isSender: true)
        
        FriendsController.createMessage(withText: "Ok, cool", friend: steve, minutesAgo: 0, context: context)
    }
    
    static func createMessage(withText: String, friend: Friend, minutesAgo: Double, context: NSManagedObjectContext, isSender: Bool = false){
        let message = Message(context: context)
        message.friend = friend
        message.text = withText
        message.date = Date().addingTimeInterval(-minutesAgo * 60)
        message.isSender = isSender
        friend.lastMessage = message
    }
    
//    func loadData(){
//        if let delegate = UIApplication.shared.delegate as? AppDelegate {
//            let context = delegate.persistentContainer.viewContext
//
//            if let friends = fetchFriends() {
//                messages = [Message]()
//                for friend in friends {
//                    let fetchRequest: NSFetchRequest = Message.fetchRequest()
//                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
//                    fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
//                    fetchRequest.fetchLimit = 1
//
//                    do {
//                        let fetechedMessages = try (context.fetch(fetchRequest)) as [Message]
//                        messages?.append(contentsOf: fetechedMessages)
//                    } catch let err {
//                        print(err)
//                    }
//                }
//
//                messages?.sort(by: { $0.0.date?.compare($0.1.date!) == .orderedDescending })
//            }
//        }
//    }
    
//    private func fetchFriends() -> [Friend]? {
//        if let delegate = UIApplication.shared.delegate as? AppDelegate {
//            let context = delegate.persistentContainer.viewContext
//            let request: NSFetchRequest = Friend.fetchRequest()
//            do{
//                return try context.fetch(request) as [Friend]
//            }catch let err {
//                print(err)
//            }
//        }
//        return nil
//    }
}
