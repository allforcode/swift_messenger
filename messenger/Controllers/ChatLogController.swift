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
                messages?.sort(by: { $0.0.date?.compare($0.1.date!) == .orderedDescending })
            }
        }
    }
    
    var messages: [Message]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
}

class ChatLogMessageCell: BaseCell {
    
    var messageTextView: UITextView = {
        let v = UITextView()
        v.font = UIFont.systemFont(ofSize: 16)
        v.text = "some message"
        return v
    }()
    
    let dividerLineView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return v
    }()
    
    override func setupViews() {
        super.setupViews()
        backgroundColor = .blue
        addSubview(messageTextView)
        addConstraints(format: "H:|[v0]|", views: messageTextView)
        addConstraints(format: "V:|[v0]|", views: messageTextView)
    }
}
