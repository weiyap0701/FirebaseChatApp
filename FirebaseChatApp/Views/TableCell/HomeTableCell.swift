//
//  HomeCollectionCell.swift
//  FirebaseChatApp
//
//  Created by Ong Wei Yap on 13/1/19.
//  Copyright © 2019 Ong Wei Yap. All rights reserved.
//

import Foundation
import UIKit

class HomeTableCell: BaseTableCell {
    
    let profileImageView: WyImageView = {
        let imageView = WyImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    var message: Message? {
        
        didSet {
            
            if (message?.isReceiver)! { 
                if let profileImageUrl = message?.fromUser?.profileImageUrl {
                    profileImageView.network(urlString: profileImageUrl)
                }
                
                if let name = message?.fromUser?.name {
                    nameLabel.text = name
                }
            }
            else {
                if let profileImageUrl = message?.toUser?.profileImageUrl {
                    profileImageView.network(urlString: profileImageUrl)
                }
                
                if let name = message?.toUser?.name {
                    nameLabel.text = name
                }
            }
            
            if let text = message?.text {
                messageLabel.text = text
            }
            
            if let timestamp = message?.timestamp {
                let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate)
            }
            
        }
        
    }
    
    override func createView() {
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(timeLabel)
        addSubview(messageLabel)
        
        profileImageView.anchorViewWithConstantsTo(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 12, bottomConstant: 0, rightConstant: 0)
        profileImageView.anchorViewWithHeightAndWidthConstant(height: 50, width: 50)
        
        timeLabel.anchorViewWithConstantsTo(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 12, leftConstant: 0, bottomConstant: 0, rightConstant: 12)
        timeLabel.anchorViewWithHeightAndWidthConstant(height: 20, width: 100)
        
        nameLabel.anchorViewWithConstantsTo(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: timeLabel.leftAnchor, topConstant: 12, leftConstant: 6, bottomConstant: 0, rightConstant: 12)
        nameLabel.anchorViewWithHeightConstant(height: 30)
        
        messageLabel.anchorViewWithConstantsTo(top: nameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 6, bottomConstant: 0, rightConstant: 12)
        messageLabel.anchorViewWithHeightConstant(height: 30)
        
        createDivider()
    }
    
}













