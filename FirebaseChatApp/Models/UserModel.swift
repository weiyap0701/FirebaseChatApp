//
//  User.swift
//  FirebaseChatApp
//
//  Created by Ong Wei Yap on 14/1/19.
//  Copyright © 2019 Ong Wei Yap. All rights reserved.
//

import UIKit

class UserModel: NSObject, Codable {
    
    var userId: String
    var name: String?
    var email: String?
    var profileImageUrl: String?
    
    init(json: [String: AnyObject], userId: String) {
        self.userId = userId
        self.name = json["name"] as? String
        self.email = json["email"] as? String
        self.profileImageUrl = json["profileImageUrl"] as? String
    }
    
    func encode(currentUser: UserModel) {
        if let encoded = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
    
    static func decode() -> UserModel? {
        if let currentUserData = UserDefaults.standard.data(forKey: "currentUser"),
            let currentUser = try? JSONDecoder().decode(UserModel.self, from: currentUserData) {
            return currentUser
        }
        return nil
    }
}











