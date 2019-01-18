//
//  NewMessageTableCell.swift
//  FirebaseChatApp
//
//  Created by Ong Wei Yap on 14/1/19.
//  Copyright © 2019 Ong Wei Yap. All rights reserved.
//

import Foundation
import UIKit

class NewMessageTableCell: BaseTableCell {
    
    //MARK: UI
    let profileImageView: WyImageView = {
        let imageView = WyImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 22
        imageView.backgroundColor = .lightGray
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    //MARK: Variables
    var user: UserModel? {
        didSet {
            
            if let profileImageUrl = user?.profileImageUrl {
                profileImageView.network(urlString: profileImageUrl)
            }
            
            nameLabel.text = user?.name
        }
    }
    
    override func createView() {
        
        addSubview(profileImageView)
        profileImageView.centerViewWithY(y: centerYAnchor)
        profileImageView.anchorViewWithHeightAndWidthConstant(height: 44, width: 44)
        profileImageView.anchorViewWithConstantsTo(top: nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 0)
        
        addSubview(nameLabel)
        nameLabel.centerViewWithY(y: centerYAnchor)
        nameLabel.anchorViewWithConstantsTo(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 12)
        
        createDivider()
    }
    
}














