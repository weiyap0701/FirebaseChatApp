//
//  ChatLogCollectionCell.swift
//  FirebaseChatApp
//
//  Created by Ong Wei Yap on 14/1/19.
//  Copyright © 2019 Ong Wei Yap. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class ChatLogCollectionCell: BaseCollectionCell {
    
    //MARK: UI
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 0, green: 137, blue: 249)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let messageImageView: WyImageView = {
        let imageView = WyImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        textView.isEditable = false
        return textView
    }()
    
    lazy var playVideoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "playVideoLogo1"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(playVideoButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let videoLoadingIndicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    //MARK: Variables
    var widthConstant: CGFloat? {
        didSet {
            bubbleViewWidthConstraint?.isActive = false
            bubbleViewWidthConstraint = bubbleView.widthAnchor.constraint(equalToConstant: widthConstant!)
            bubbleViewWidthConstraint?.isActive = true
        }
    }
    var message: Message? {
        didSet {
            
            if message?.messageMedia?.videoUrl != nil {
                playVideoButton.isHidden = false
            }
            else {
                playVideoButton.isHidden = true
            }
            
            if let messageImageUrl = message?.messageMedia?.imageUrl {
                messageImageView.isHidden = false
                messageTextView.isHidden = true
                messageImageView.network(urlString: messageImageUrl)
            }
            else {
                messageImageView.isHidden = true
                messageTextView.isHidden = false
            }
            
            if let text = message?.text {
                messageTextView.text = text
            }
            
            if let isReceiver = message?.isReceiver {
                
                bubbleViewRightConstraint?.isActive = !isReceiver
                bubbleViewLeftConstraint?.isActive = isReceiver
                
                if isReceiver { //Receiving message
                    bubbleView.backgroundColor = UIColor.rgb(red: 0, green: 137, blue: 249)
                    messageTextView.textColor = .white
                    
                }
                else {
                    bubbleView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
                    messageTextView.textColor = .darkGray
                    
                }
            }
            
        }
    }
    
    var bubbleViewWidthConstraint: NSLayoutConstraint?
    var bubbleViewLeftConstraint: NSLayoutConstraint?
    var bubbleViewRightConstraint: NSLayoutConstraint?
    
    @objc private func playVideoButtonPressed() {
        playVideo()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        videoLoadingIndicatorView.stopAnimating()
    }
    
    override func createView() {
        createBubbleView()
        addSubview(messageImageView)
        addSubview(messageTextView)
        addSubview(playVideoButton)
        addSubview(videoLoadingIndicatorView)
    
        messageImageView.anchorViewTo(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor)
        messageTextView.anchorViewWithConstantsTo(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: bottomAnchor, right: bubbleView.rightAnchor, topConstant: 0, leftConstant: 6, bottomConstant: 0, rightConstant: 6)
        
        playVideoButton.centerViewWithX(x: bubbleView.centerXAnchor)
        playVideoButton.centerViewWithY(y: bubbleView.centerYAnchor)
        playVideoButton.anchorViewWithHeightAndWidthConstant(height: 50, width: 50)
        
        videoLoadingIndicatorView.centerViewWithX(x: bubbleView.centerXAnchor)
        videoLoadingIndicatorView.centerViewWithY(y: bubbleView.centerYAnchor)
        videoLoadingIndicatorView.anchorViewWithHeightAndWidthConstant(height: 50, width: 50)
        
        messageImageView.isHidden = true
        playVideoButton.isHidden = true
    }
    
    private func createBubbleView() {
        addSubview(bubbleView)

        bubbleView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        bubbleViewLeftConstraint = bubbleView.leftAnchor.constraint(equalTo: leftAnchor, constant: 6)
        bubbleViewRightConstraint = bubbleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -6)
    }
    
    private func playVideo() {
        if let videoUrlString = message?.messageMedia?.videoUrl, let videoUrl = URL(string: videoUrlString) {

            player = AVPlayer(url: videoUrl)
            player?.addObserver(self, forKeyPath: "timeControlStatus", options: NSKeyValueObservingOptions.new, context: nil)

            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.cornerRadius = 10
            playerLayer?.masksToBounds = true
            playerLayer?.frame = CGRect(x: 0, y: 0, width: bubbleView.frame.width, height: bubbleView.frame.height)

            bubbleView.layer.addSublayer(playerLayer!)

            playVideoButton.isHidden = true

            player?.play()
            
            videoLoadingIndicatorView.startAnimating()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus" {
            if player?.timeControlStatus == .playing {
                messageImageView.isHidden = true
                videoLoadingIndicatorView.stopAnimating()
            }
        }
    }
}


























