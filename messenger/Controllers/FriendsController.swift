//
//  FriendsController.swift
//  messenger
//
//  Created by Paul Dong on 15/10/17.
//  Copyright © 2017 Paul Dong. All rights reserved.
//

import UIKit
import CoreData

class FriendsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {

    private let cellId = "cellId"
    
//    var messages: [Message]?
    
    lazy var fetchedResultsController: NSFetchedResultsController<Friend> = {
        let fetchRequest: NSFetchRequest = Friend.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessage.date", ascending: false)]
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        blockOperations.append(BlockOperation(block: {
            self.collectionView?.insertItems(at: [newIndexPath!])
        }))
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            for blockOperation in blockOperations {
                blockOperation.start()
            }
        }, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        collectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Recent"
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
        setupData()
        
        do {
            try fetchedResultsController.performFetch()
        }catch let err {
            print(err)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Mark", style: .plain, target: self, action: #selector(addMark))
    }

    func addMark(){
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            let context = delegate.persistentContainer.viewContext
            //mark
            let mark = Friend(context: context)
            mark.name = "Mark Zuckerberg"
            mark.profileImageName = "zuckprofile"
            
            let text = "Hello, my name is Mark, Nice to meet you ..."
            FriendsController.createMessage(withText: text, friend: mark, minutesAgo: 3, context: context)
            
            FriendsController.createMessage(withText: "Nice to meet you.", friend: mark, minutesAgo: 0, context: context, isSender: true)
            
            let bill = Friend(context: context)
            bill.name = "Bill Gates"
            bill.profileImageName = "bill_gates"
            
            FriendsController.createMessage(withText: "Hello, my name is Bill, Nice to meet you ...", friend: bill, minutesAgo: 3, context: context)
            
            FriendsController.createMessage(withText: "Nice to meet you.", friend: bill, minutesAgo: 0, context: context, isSender: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = fetchedResultsController.sections?[section].numberOfObjects {
            return count
        }
        return 0
    }
    
    var blockOperations = [BlockOperation]()
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
        
        let friend = fetchedResultsController.object(at: indexPath)
        cell.message = friend.lastMessage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        let controller = ChatLogController(collectionViewLayout: layout)
        controller.friend = fetchedResultsController.object(at: indexPath)
        navigationController?.pushViewController(controller, animated: true)
    }
}

class MessageCell: BaseCell {
    
    var message: Message? {
        didSet {
            if let name = message?.friend?.name {
                nameLabel.text = name
            }
            
            if let imageName = message?.friend?.profileImageName {
                profileImageView.image = UIImage(named: imageName)
                hasReadImageView.image = UIImage(named: imageName)
            }
            
            if let message = message?.text {
                messageLabel.text = message
            }
            
            if let date = message?.date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                
                let elapsedTimeInSeconds = Date().timeIntervalSince(date)
                let secondInDays: TimeInterval = 60 * 60 * 24
                
                if elapsedTimeInSeconds > 7 * secondInDays {
                    dateFormatter.dateFormat = "dd/MM/yy"
                }else if elapsedTimeInSeconds > secondInDays {
                    dateFormatter.dateFormat = "EEE"
                }
                
                let time = dateFormatter.string(from: date)
                timeLabel.text = "\(time)"
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.rgb(red: 0, green: 134, blue: 249) : UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            messageLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            timeLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        //half of height to make it round clycle
        iv.layer.cornerRadius = 34
        iv.layer.masksToBounds = true
        iv.image = UIImage(named: "zuckprofile")
        return iv
    }()
    
    let dividerLineView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return v
    }()
    
    let nameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 18)
        l.text = "Friend Name"
        return l
    }()
    
    let messageLabel: UILabel = {
        let l = UILabel()
        l.textColor = .darkGray
        l.font = UIFont.systemFont(ofSize: 14)
        l.text = "Your friend's message and something else ..."
        return l
    }()
    
    let timeLabel: UILabel = {
        let l = UILabel()
        l.textColor = .gray
        l.textAlignment = .right
        l.font = UIFont.systemFont(ofSize: 16)
        l.text = "00:00 PM"
        return l
    }()
    
    let hasReadImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        //half of height to make it round clycle
        iv.layer.cornerRadius = 10
        iv.layer.masksToBounds = true
        iv.image = UIImage(named: "zuckprofile")
        return iv
    }()
    
    override func setupViews() {
//        backgroundColor = UIColor.yellow
        addSubview(profileImageView)
        addSubview(dividerLineView)
        
        setupContainerView()
        
        addConstraints(format: "H:|-12-[v0(68)]", views: profileImageView)
        addConstraints(format: "V:[v0(68)]", views: profileImageView)
        
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraints(format: "H:|-88-[v0]-4-|", views: dividerLineView)
        addConstraints(format: "V:[v0(1)]|", views: dividerLineView)
   }
    
    func setupContainerView(){
        let containerView = UIView()
//        containerView.backgroundColor = UIColor.red
        addSubview(containerView)
        
        addConstraints(format: "H:|-88-[v0]|", views: containerView)
        addConstraints(format: "V:[v0(50)]", views: containerView)
        
        //Vertically assign a View in the middle of its parent container
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(hasReadImageView)
        
        containerView.addConstraints(format: "H:|[v0][v1(80)]-12-|", views: nameLabel, timeLabel)
        containerView.addConstraints(format: "H:|[v0][v1(20)]-12-|", views: messageLabel, hasReadImageView)
        
        containerView.addConstraints(format: "V:|[v0(20)]", views: timeLabel)
        containerView.addConstraints(format: "V:|[v0]-8-[v1(24)]|", views: nameLabel, messageLabel)
        containerView.addConstraints(format: "V:[v0(20)]|", views: hasReadImageView)
    }
}

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){}
}
