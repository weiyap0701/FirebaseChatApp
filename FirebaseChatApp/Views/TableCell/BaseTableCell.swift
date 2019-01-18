//
//  BaseCollectionCell.swift
//  FirebaseChatApp
//
//  Created by Ong Wei Yap on 13/1/19.
//  Copyright © 2019 Ong Wei Yap. All rights reserved.
//

import Foundation
import UIKit

class BaseTableCell: UITableViewCell {
    
    let divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        return view
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        createView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createView() {}
    
    func createDivider() {
        addSubview(divider)
        divider.anchorViewWithConstantsTo(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        divider.anchorViewWithHeightConstant(height: 0.5)
    }
}









