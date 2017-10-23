//
//  ChatLogController.swift
//  messenger
//
//  Created by Paul Dong on 21/10/17.
//  Copyright © 2017 Paul Dong. All rights reserved.
//

import UIKit
import CoreData

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    private let cellId = "cellId"
    
    var friend: Friend? {
        didSet {
            if let name = friend?.name {
                navigationItem.title = name
            }
        }
    }
    
    let messageInputContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white
        return v
    }()
    
    let inputTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter message ..."
        return tf
    }()
    
    let sendButton: UIButton = {
        let b = UIButton(type: UIButtonType.system)
        b.setTitle("Send", for: .normal)
        b.contentHorizontalAlignment = .right
        let titleColor = UIColor.rgb(red: 0, green: 137, blue: 249)
        b.setTitleColor(titleColor, for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        b.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return b
    }()
    
    func handleSend(){
        let text = inputTextField.text!
        saveContext(messageString: text, isSender: true)
        inputTextField.text = ""
    }
    
    var bottomConstraints: NSLayoutConstraint?
    
    func simulate(){
        saveContext(messageString: "Simnulate message")
        saveContext(messageString: "Simnulate another message")
    }
    
    func saveContext(messageString: String, isSender: Bool = false){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
            
        if isSender {
            FriendsController.createMessage(withText: messageString, friend: friend!, minutesAgo: 0, context: context, isSender: true)
        } else {
            FriendsController.createMessage(withText: messageString, friend: friend!, minutesAgo: 0, context: context)
        }
        
        FriendsController.createMessage(withText: "Auto response", friend: friend!, minutesAgo: 0, context: context)
        
        do {
            try context.save()
            scrollToBottom()
        }catch let err {
            print(err)
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<Message> = {
        let fetchRequest: NSFetchRequest = Message.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        if let name = self.friend?.name {
            fetchRequest.predicate = NSPredicate(format: "friend.name = %@", name)
        }
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    var blockOperations = [BlockOperation]()
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .insert {
            blockOperations.append(BlockOperation(block: {
                self.collectionView?.insertItems(at: [newIndexPath!])
            }))
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            for blockOperation in blockOperations {
                blockOperation.start()
            }
        }, completion: { (_) in
            self.scrollToBottom()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        }catch let err {
            print(err)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simulate", style: .plain, target: self, action: #selector(simulate))
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
        tabBarController?.tabBar.isHidden = true
        collectionView?.alwaysBounceVertical = true
        
        let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 48, right: 0)
        collectionView?.contentInset = edgeInsets
        collectionView?.scrollIndicatorInsets = edgeInsets
        collectionView?.contentSize = CGSize(width: view.frame.width, height: view.frame.height - 48)
        
        view.addSubview(messageInputContainerView)
        view.addConstraints(format: "H:|[v0]|", views: messageInputContainerView)
        view.addConstraints(format: "V:[v0(48)]", views: messageInputContainerView)
        
        bottomConstraints = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraints!)
        
        setupInputComponents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        scrollToBottom()
    }
    
    public func handleKeyboardNotification(_ notification: Notification){
        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            
            let isKeyboardHide = notification.name == .UIKeyboardWillHide
            
            bottomConstraints?.constant = isKeyboardHide ? 0 : -keyboardFrame.height
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                self.scrollToBottom()
            })
        }
    }
    
    public func scrollToBottom(){
        if let count = fetchedResultsController.sections?.first?.numberOfObjects {
            let indexPath = IndexPath(item: count - 1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
    }
    
    private func setupInputComponents() {
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        
        messageInputContainerView.addConstraints([
            NSLayoutConstraint(item: inputTextField, attribute: .left, relatedBy: .equal, toItem: messageInputContainerView, attribute: .left, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: inputTextField, attribute: .right, relatedBy: .equal, toItem: messageInputContainerView, attribute: .right, multiplier: 1, constant: -80)
            ])
        
        messageInputContainerView.addConstraints(format: "H:[v0(100)]-8-|", views: sendButton)
        
        messageInputContainerView.addConstraints(format: "V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraints(format: "V:|[v0]|", views: sendButton)
        
        messageInputContainerView.addConstraints(format: "H:|[v0]|", views: topBorderView)
        messageInputContainerView.addConstraints(format: "V:|[v0(0.5)]", views: topBorderView)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = fetchedResultsController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
        
        let message = fetchedResultsController.object(at: indexPath)
        cell.messageTextView.text = message.text
        
        if let messageText = message.text, let profileImageName = message.friend?.profileImageName {
            
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            
            var x: CGFloat
            var tintColor: UIColor
            var textColor: UIColor
            var bgImage: UIImage
            var cornerRedius: CGFloat
            var profileImageSize: CGSize
            
            if message.isSender {
                x = view.frame.width - estimatedFrame.width - CGFloat(45) - 16
                tintColor = UIColor.rgb(red: 0, green: 137, blue: 249)
                textColor = UIColor.white
                bgImage = ChatLogMessageCell.blueBubble!
                profileImageSize = CGSize(width: 20, height: 20)
                cornerRedius = 10
                for constraint in cell.profileImageConstraints! {
                    if constraint.firstAttribute == .left {
                        constraint.constant = cell.frame.width - 8 - 20
                    }
                }
            }else {
                x = 45
                tintColor = UIColor(white: 0.95, alpha: 1)
                textColor = UIColor.black
                bgImage = ChatLogMessageCell.grayBubble!
                profileImageSize = CGSize(width: 30, height: 30)
                cornerRedius = 15
                for constraint in cell.profileImageConstraints! {
                    if constraint.firstAttribute == .left {
                        constraint.constant = 0
                    }
                }
            }
            
            cell.profileImageView.image = resizeImage(image: UIImage(named: profileImageName)!, size: profileImageSize)
            cell.messageTextView.frame = CGRect(x: x + 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
            cell.textBubbleView.frame = CGRect(x: x - 8, y: -4, width: estimatedFrame.width + 16 + 8 + 24, height: estimatedFrame.height + 20 + 8)
            cell.textBubbleImageView.image = bgImage
            cell.textBubbleImageView.tintColor = tintColor
            cell.messageTextView.textColor = textColor
            
            cell.profileImageView.layer.cornerRadius = cornerRedius
        }
        
        return cell
    }
    
    func resizeImage(image: UIImage, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndPDFContext()
        return newImage!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let message = fetchedResultsController.object(at: indexPath)
        if let messageText = message.text {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
        }
        
        return CGSize(width: view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
}

class ChatLogMessageCell: BaseCell {
    
    var messageTextView: UITextView = {
        let v = UITextView()
        v.font = UIFont.systemFont(ofSize: 18)
        v.backgroundColor = UIColor.clear
        v.isEditable = false
        v.text = "some message"
        return v
    }()
    
    let textBubbleView: UIView = {
        let v = UIView()
//        v.backgroundColor = UIColor(white: 0.95, alpha: 1)
        v.layer.cornerRadius = 15
        v.layer.masksToBounds = true
        return v
    }()
    
    let textBubbleImageView: UIImageView = {
        let v = UIImageView()
        return v
    }()
    
    var profileImageConstraints: [NSLayoutConstraint]?
    
    static let grayBubble = UIImage(named: "bubble_gray")?.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    static let blueBubble = UIImage(named: "bubble_blue")?.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.image = UIImage(named: "zuckprofile")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override func setupViews() {
        super.setupViews()
        addSubview(textBubbleView)
        addSubview(messageTextView)
        addSubview(profileImageView)
        
        profileImageConstraints = [
            NSLayoutConstraint(item: profileImageView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: profileImageView, attribute: .bottom, relatedBy: .equal, toItem: textBubbleView, attribute: .bottom, multiplier: 1, constant: 0)
        ]
        addConstraints(profileImageConstraints!)
        
        textBubbleView.addSubview(textBubbleImageView)
        addConstraints(format: "H:|[v0]|", views: textBubbleImageView)
        addConstraints(format: "V:|[v0]|", views: textBubbleImageView)
    }
}
