//
//  ChatLogController.swift
//  messenger
//
//  Created by Paul Dong on 21/10/17.
//  Copyright © 2017 Paul Dong. All rights reserved.
//

import UIKit

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private let cellId = "cellId"
    
    var friend: Friend? {
        didSet {
            if let name = friend?.name {
                navigationItem.title = name
                messages = friend?.messages?.allObjects as? [Message]
                messages?.sort(by: { $0.0.date?.compare($0.1.date!) == .orderedAscending })
            }
        }
    }
    
    var messages: [Message]?
    
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
        let titleColor = UIColor.rgb(red: 0, green: 137, blue: 249)
        b.setTitleColor(titleColor, for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return b
    }()
    
    var bottomConstraints: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
        tabBarController?.tabBar.isHidden = true
        collectionView?.alwaysBounceVertical = true
        
        let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 96, right: 0)
        collectionView?.contentInset = edgeInsets
        collectionView?.scrollIndicatorInsets = edgeInsets
        
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
        let indexPath = IndexPath(item: self.messages!.count - 1, section: 0)
        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
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
        
        messageInputContainerView.addConstraints(format: "H:|-8-[v0][v1]-8-|", views: inputTextField, sendButton)
        messageInputContainerView.addConstraints(format: "V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraints(format: "V:|[v0]|", views: sendButton)
        
        messageInputContainerView.addConstraints(format: "H:|[v0]|", views: topBorderView)
        messageInputContainerView.addConstraints(format: "V:|[v0(0.5)]", views: topBorderView)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = messages?.count {
            return count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
        cell.messageTextView.text = messages?[indexPath.item].text
        
        if let message = messages?[indexPath.item], let messageText = message.text, let profileImageName = message.friend?.profileImageName {
            
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            
            var x: CGFloat
            var tintColor: UIColor
            var textColor: UIColor
            var bgImage: UIImage
            var constraints: (String, String)
            var cornerRedius: CGFloat
            
            if message.isSender {
                x = view.frame.width - estimatedFrame.width - CGFloat(45) - 16
                tintColor = UIColor.rgb(red: 0, green: 137, blue: 249)
                textColor = UIColor.white
                bgImage = ChatLogMessageCell.blueBubble!
                constraints = ChatLogMessageCell.getBlueBublleProfileImageConstraintStrings()
                cornerRedius = 10
            }else {
                x = 45
                tintColor = UIColor(white: 0.95, alpha: 1)
                textColor = UIColor.black
                bgImage = ChatLogMessageCell.grayBubble!
                constraints = ChatLogMessageCell.getGrayBublleProfileImageConstraint()
                cornerRedius = 15
            }
            
            cell.profileImageView.image = UIImage(named: profileImageName)
            cell.messageTextView.frame = CGRect(x: x + 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
            cell.textBubbleView.frame = CGRect(x: x - 12, y: -4, width: estimatedFrame.width + 16 + 8 + 24, height: estimatedFrame.height + 20 + 8)
            cell.textBubbleImageView.image = bgImage
            cell.textBubbleImageView.tintColor = tintColor
            cell.messageTextView.textColor = textColor
            
            cell.profileImageView.layer.cornerRadius = cornerRedius
            cell.addConstraints(format: constraints.0, views: cell.profileImageView)
            cell.addConstraints(format: constraints.1, views: cell.profileImageView)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let messageText = messages?[indexPath.item].text {
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
    
    static let grayBubble = UIImage(named: "bubble_gray")?.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    static let blueBubble = UIImage(named: "bubble_blue")?.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.image = UIImage(named: "zuckprofile")
        return iv
    }()
    
    override func setupViews() {
        super.setupViews()
        addSubview(textBubbleView)
        addSubview(messageTextView)
        addSubview(profileImageView)
//        let constraints = ("H:[v0(20)]-8-|", "V:[v0(20)]|")
//        addConstraints(format: constraints.0, views: profileImageView)
//        addConstraints(format: constraints.1, views: profileImageView)
        
        textBubbleView.addSubview(textBubbleImageView)
        addConstraints(format: "H:|[v0]|", views: textBubbleImageView)
        addConstraints(format: "V:|[v0]|", views: textBubbleImageView)
    }
    
    static func getBlueBublleProfileImageConstraintStrings() -> (String, String){
        return ("H:[v0(20)]-8-|", "V:[v0(20)]|")
    }
    
    static func getGrayBublleProfileImageConstraint() -> (String, String){
        return ("H:|-8-[v0(30)]", "V:[v0(30)]|")
    }
}
