//
//  Message.swift
//  FirebaseChatApp
//
//  Created by Ong Wei Yap on 14/1/19.
//  Copyright © 2019 Ong Wei Yap. All rights reserved.
//

import Foundation
import UIKit

class Message: NSObject {
    
    var fromUserId: String?
    var text: String?
    var messageMedia: MessageMedia?
    var timestamp: Int?
    var toUser: UserModel?
    var fromUser: UserModel?
    var isReceiver = false
    
    init(json: [String: AnyObject]) {
        self.fromUserId = json["fromUserId"] as? String
        self.text = json["text"] as? String
        self.timestamp = json["timestamp"] as? Int
        
        if let messageImageDic = json["messageMedia"] as? [String: AnyObject] {
            self.messageMedia = MessageMedia(json: messageImageDic)
        }
        
        if let dic = json["toUser"] as? [String: AnyObject] {
            
            if let userId = dic["userId"] as? String {
                self.toUser = UserModel(json: dic, userId: userId)
            }
            
        }
        
        if let dic2 = json["fromUser"] as? [String: AnyObject] {
            
            if let userId = dic2["userId"] as? String {
                self.fromUser = UserModel(json: dic2, userId: userId)
            }
            
        }
        self.isReceiver = self.toUser?.userId == UserModel.decode()?.userId ? true : false
    }
}


class MessageMedia: NSObject {
    
    var videoUrl: String?
    var imageUrl: String?
    var imageWidth: CGFloat?
    var imageHeight: CGFloat?
    var isVideo = false
    
    init(json: [String: AnyObject]) {
        self.videoUrl = json["videoUrl"] as? String
        self.imageUrl = json["imageUrl"] as? String
        self.imageWidth = json["imageWidth"] as? CGFloat
        self.imageHeight = json["imageHeight"] as? CGFloat
        self.isVideo = self.videoUrl != nil ? true : false
    }
    
}












