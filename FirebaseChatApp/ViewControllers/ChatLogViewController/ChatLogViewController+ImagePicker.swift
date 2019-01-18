//
//  ChatLogViewController+ImagePicker.swift
//  FirebaseChatApp
//
//  Created by Ong Wei Yap on 16/1/19.
//  Copyright © 2019 Ong Wei Yap. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import AVFoundation

extension ChatLogViewController {
    
    func showImagePickerController() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    private func uploadImage(image: UIImage) {
        loadingIndicatorView.startAnimating()
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            FirebaseService.shared.uploadImage(imageData: uploadData, isMessageImage: true) { (messageImageUrl) in
                if let imageUrl = messageImageUrl {
                    FirebaseService.shared.sendImageMessage(toUser: self.toUser, imageUrl: imageUrl, imageWidth: image.size.width, imageHeight: image.size.height)
                }
                self.loadingIndicatorView.stopAnimating()
            }
        }
    }
    
    private func uploadVideo(localVideoUrl: URL) {
        loadingIndicatorView.startAnimating()
        FirebaseService.shared.uploadVideo(localVideoUrl: localVideoUrl) { (videoUrl, thumbnailUrl, thumbnailWidth, thumbnailHeight) in
            if let videoUrlString = videoUrl, let thumbnailUrlString = thumbnailUrl {
                FirebaseService.shared.sendVideoMessage(toUser: self.toUser, videoUrl: videoUrlString, thumbnailUrl: thumbnailUrlString, thumbnailWidth: thumbnailWidth, thumbnailHeight: thumbnailHeight)
                self.loadingIndicatorView.stopAnimating()
            }
        }
    }
    
    //MARK: Delegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            uploadVideo(localVideoUrl: videoUrl)
        }
        else {
            if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
                uploadImage(image: editedImage)
            }
            else if let oriImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                uploadImage(image: oriImage)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
}
















