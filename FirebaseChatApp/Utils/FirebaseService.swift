//
//  FirebaseService.swift
//  FirebaseChatApp
//
//  Created by Ong Wei Yap on 13/1/19.
//  Copyright © 2019 Ong Wei Yap. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import AVFoundation

class FirebaseService: NSObject {
    
    //MARK: Variables
    static let shared = FirebaseService()
    let reference = Database.database().reference()
    let storage = Storage.storage().reference()
    let auth = Auth.auth()
    
    //MARK: Register, Login, Logout
    func registerUserWithEmail(email: String, password: String, completion: @escaping (User?, Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(user, nil)
            }
            
        }
    }
    
    func updateUserToDatabase(uid: String, name: String, email: String, profileImageUrl: String? = nil, completion: @escaping (Error?) -> ()) {
        
        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
        let userReference = reference.child("users").child(uid)
        userReference.updateChildValues(values, withCompletionBlock: { (error, databaseRef) in
            
            if error != nil {
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(nil)
            }
            
        })
    }
    
    func loginUserWithEmail(email: String, password: String, completion: @escaping (User?, Error?) -> ()) {
        
        auth.signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(user, nil)
            }
        }
    }
    
    func isLoggedIn() -> Bool {
        let isLoggedIn = auth.currentUser?.uid == nil ? false : true
        return isLoggedIn
    }
    
    func signOut() {
        do {
            try auth.signOut()
        } catch let error {
            print(error)
        }
    }
    
    //MARK: User
    func getUserInfo(completion: @escaping (UserModel) -> ()) {
        guard let uid = auth.currentUser?.uid else { return }
        reference.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            
            if let dic = snapshot.value as? [String: AnyObject] {
                let user = UserModel(json: dic, userId: uid)
                user.encode(currentUser: user)
                DispatchQueue.main.async {
                    completion(user)
                }
            }
            
        }
    }
    
    func getUserList(completion: @escaping (UserModel) -> ()) {
        reference.child("users").observe(.childAdded, with: { (snapshot) in
            if let dic = snapshot.value as? [String: AnyObject] {
                
                let user = UserModel(json: dic, userId: snapshot.key)
                
                DispatchQueue.main.async {
                    completion(user)
                }
            }
        }, withCancel: nil)
    }
    
    //MARK: Message
    func loadHomeMessages(completion: @escaping (Message) -> ()) {
        guard let uid = auth.currentUser?.uid else { return }
        
        let userMessageRef = reference.child("userMessages").child(uid)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            let userMessageRef2 = userMessageRef.child(userId)
            
            userMessageRef2.observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                let messageRef = self.reference.child("messages").child(messageId)
                messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dic = snapshot.value as? [String: AnyObject] {
                        let message = Message(json: dic)
                        
                        DispatchQueue.main.async {
                            completion(message)
                        }
                    }
                })
            })
        }, withCancel: nil)
    }
    
    func loadChatLogMessages(toUser: UserModel, completion: @escaping (Message) -> ()) {
        guard let uid = auth.currentUser?.uid else { return }
        let userMessageRef = reference.child("userMessages").child(uid).child(toUser.userId)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messageRef = self.reference.child("messages").child(messageId)
            
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dic = snapshot.value as? [String: AnyObject] {
                    let message = Message(json: dic)
                    
                    DispatchQueue.main.async {
                        completion(message)
                    }
                }
            })
            
        }, withCancel: nil)
    }
    
    func sendMessage(toUser: UserModel, text: String) {

        guard let fromUser = UserModel.decode() else { return }
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let toUserValues = ["userId": toUser.userId, "name": toUser.name, "email": toUser.email, "profileImageUrl": toUser.profileImageUrl]
        let fromUserValues = ["userId": fromUser.userId, "name": fromUser.name, "email": fromUser.email, "profileImageUrl": fromUser.profileImageUrl]
        
        let values = ["text": text, "toUser": toUserValues, "fromUser": fromUserValues, "timestamp": timestamp] as [String : AnyObject]
    
        sendValues(values: values, fromUserId: fromUser.userId, toUserId: toUser.userId)
    }
    
    func sendImageMessage(toUser: UserModel, imageUrl: String, imageWidth: CGFloat, imageHeight: CGFloat) {
    
        guard let fromUser = UserModel.decode() else { return }
    
        let timestamp = Int(Date().timeIntervalSince1970)
        let messageImageValues = ["imageUrl": imageUrl, "imageWidth": imageWidth, "imageHeight": imageHeight] as [String : Any]
        let toUserValues = ["userId": toUser.userId, "name": toUser.name, "email": toUser.email, "profileImageUrl": toUser.profileImageUrl]
        let fromUserValues = ["userId": fromUser.userId, "name": fromUser.name, "email": fromUser.email, "profileImageUrl": fromUser.profileImageUrl]
        
        let values = ["text": "(Image)", "messageMedia": messageImageValues, "toUser": toUserValues, "fromUser": fromUserValues, "timestamp": timestamp] as [String : AnyObject]
        
        sendValues(values: values, fromUserId: fromUser.userId, toUserId: toUser.userId)
    }
    
    func sendVideoMessage(toUser: UserModel, videoUrl: String, thumbnailUrl: String, thumbnailWidth: CGFloat, thumbnailHeight: CGFloat) {
        guard let fromUser = UserModel.decode() else { return }
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let messageVideoValues = ["videoUrl": videoUrl, "imageUrl": thumbnailUrl, "imageWidth": thumbnailWidth, "imageHeight": thumbnailHeight] as [String : Any]
        let toUserValues = ["userId": toUser.userId, "name": toUser.name, "email": toUser.email, "profileImageUrl": toUser.profileImageUrl]
        let fromUserValues = ["userId": fromUser.userId, "name": fromUser.name, "email": fromUser.email, "profileImageUrl": fromUser.profileImageUrl]
        
        let values = ["text": "(Video)", "messageMedia": messageVideoValues, "toUser": toUserValues, "fromUser": fromUserValues, "timestamp": timestamp] as [String : AnyObject]
        
        sendValues(values: values, fromUserId: fromUser.userId, toUserId: toUser.userId)
    }
    
    private func sendValues(values: [String: AnyObject], fromUserId: String, toUserId: String) {
        let messageRef = reference.child("messages")
        let childRef = messageRef.childByAutoId()
        
        childRef.updateChildValues(values) { (error, databaseRef) in
            
            if error != nil {
                print(error ?? "")
                return
            }
            
            let userMessageRef = self.reference.child("userMessages").child(fromUserId).child(toUserId)
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId: 1])
            
            let receiverUserMessageRef = self.reference.child("userMessages").child(toUserId).child(fromUserId)
            receiverUserMessageRef.updateChildValues([messageId: 2])
        }
    }
    
    func deleteHomeMessage(message: Message, completion: @escaping (Error?, String?) -> ()) {
        guard let uid = UserModel.decode()?.userId else { return }
        
        var partnerId: String?
        if uid == message.fromUser?.userId {
            partnerId = message.toUser?.userId
        }
        else {
            partnerId = message.fromUser?.userId
        }
        if let partnerUid = partnerId {
            reference.child("userMessages").child(uid).child(partnerUid).removeValue { (error, databaseRef) in
                
                if error != nil {
                    print(error ?? "")
                    DispatchQueue.main.async {
                        completion(error, nil)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completion(nil, partnerUid)
                }
            }
        }
    }
    
    //MARK: Upload media
    func uploadImage(imageData: Data, isMessageImage: Bool, completion: @escaping (String?) -> ()) {
        
        var folderName = "userProfileImages"
        if  isMessageImage {
            folderName = "messageImages"
        }
        
        let imageName = UUID().uuidString
        let storageRef = storage.child(folderName).child(imageName)
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            
            if error != nil {
                print(error ?? "")
                return
            }
            
            storageRef.downloadURL(completion: { (url, error2) in
                
                if error2 != nil {
                    print(error2 ?? "")
                    return
                }
                
                DispatchQueue.main.async {
                    completion(url?.absoluteString)
                }

            })
            
        }
    }
    
    func uploadVideo(localVideoUrl: URL, completion: @escaping (String?, String?, CGFloat, CGFloat) -> ()) { //Video url, thumbnail url, thumbnail width, thumbnail height
        
        let videoName = "video" + UUID().uuidString
        let storageRef = storage.child("messageVideos").child(videoName)
        let thumbnail = getThumbnailForVideo(localVideoUrl: localVideoUrl)
        
        let uploadTask = storageRef.putFile(from: localVideoUrl, metadata: nil) { (metadata, error) in
            if error != nil {
                print("Failed uploading video: ", error ?? "")
                return
            }
            
            storageRef.downloadURL(completion: { (videoUrl, error2) in
                if error2 != nil {
                    print(error2 ?? "")
                    return
                }
                
                if let thumbnailImage = thumbnail, let uploadData = UIImageJPEGRepresentation(thumbnailImage, 0.2) {
                    
                    self.uploadThumbnail(imageData: uploadData, completion: { (thumbnailUrl) in
                        
                        DispatchQueue.main.async {
                            completion(videoUrl?.absoluteString, thumbnailUrl, thumbnailImage.size.width, thumbnailImage.size.height)
                        }
                        
                    })
                    
                }
                else {
                    print("Failed getting thumbnail data")
                    return
                }
            })
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            print("Video upload progress: ", snapshot.progress?.completedUnitCount)
        }
    }
    
    private func uploadThumbnail(imageData: Data, completion: @escaping (String?) -> ()) {
        let imageName = "Thumbnail" + UUID().uuidString
        let storageRef = storage.child("Thumbnail").child(imageName)
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            
            if error != nil {
                print(error ?? "")
                return
            }
            
            storageRef.downloadURL(completion: { (url, error2) in
                
                if error2 != nil {
                    print(error2 ?? "")
                    return
                }
                
                DispatchQueue.main.async {
                    completion(url?.absoluteString)
                }
                
            })
            
        }
    }
    
    private func getThumbnailForVideo(localVideoUrl: URL) -> UIImage? {
        let asset = AVAsset(url: localVideoUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnail = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnail)
        } catch let err {
            print(err)
        }
        return nil
    }
}




























