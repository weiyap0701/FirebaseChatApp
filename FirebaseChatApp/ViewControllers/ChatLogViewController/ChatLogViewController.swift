//
//  ChatLogViewController.swift
//  FirebaseChatApp
//
//  Created by Ong Wei Yap on 14/1/19.
//  Copyright © 2019 Ong Wei Yap. All rights reserved.
//

import Foundation
import UIKit

class ChatLogViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //MARK: UI
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.contentInset = UIEdgeInsetsMake(12, 0, 12, 0)
        cv.showsVerticalScrollIndicator = false
        cv.alwaysBounceVertical = true
        cv.keyboardDismissMode = .interactive
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let loadingIndicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator.backgroundColor = UIColor(white: 0, alpha: 0.4)
        indicator.layer.cornerRadius = 10
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    lazy var inputContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let inputDivider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        return view
    }()
    
    let uploadImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "uploadImageIcon1"), for: .normal)
        button.addTarget(self, action: #selector(uploadImageButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type something here..."
        textField.delegate = self
        return textField
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)
        return button
    }()
    
    //MARK: Variables
    var toUser: UserModel!
    var messages = [Message]()
    var inputContainerBottomConstraint: NSLayoutConstraint?
    
//    override var inputAccessoryView: UIView? {
//        get {
//            let containerView = UIView()
//            containerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
//            containerView.backgroundColor = .yellow
//            return inputContainer
//        }
//    }
    
//    override var canBecomeFirstResponder: Bool {
//        return true
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(performKeyboardAction), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(performKeyboardAction), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        createInputContainer()
        createCollectionView()
        createIndicatorView()
        loadMessages()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Objc func
    @objc private func sendButtonPressed() {
        sendMessage()
    }
    
    @objc private func uploadImageButtonPressed() {
        sendImage()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func performKeyboardAction(notification: Notification) {
        if notification.name == Notification.Name.UIKeyboardWillShow {
            if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                inputContainerBottomConstraint?.constant = -keyboardHeight
            }
        }
        else if notification.name == Notification.Name.UIKeyboardWillHide {
            inputContainerBottomConstraint?.constant = 0
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) { (completed) in
            self.scrollToLastMessageWithAnimation()
        }
    }
    
    //MARK: Private func
    private func createCollectionView() {
        view.addSubview(collectionView)
        let safeArea = view.safeAreaLayoutGuide
        collectionView.anchorViewWithConstantsTo(top: safeArea.topAnchor, left: view.leftAnchor, bottom: inputContainer.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        collectionView.register(ChatLogCollectionCell.self, forCellWithReuseIdentifier: "ChatLogCollectionCell")
    }
    
    private func createIndicatorView() {
        view.addSubview(loadingIndicatorView)
        loadingIndicatorView.centerViewWithY(y: view.centerYAnchor)
        loadingIndicatorView.centerViewWithX(x: view.centerXAnchor)
        loadingIndicatorView.anchorViewWithHeightAndWidthConstant(height: 50, width: 50)
    }
    
    private func createInputContainer() {
        view.addSubview(inputContainer)
        let safeArea = view.safeAreaLayoutGuide
        inputContainer.leftAnchor.constraint(equalTo: safeArea.leftAnchor, constant: 0).isActive = true
        inputContainer.rightAnchor.constraint(equalTo: safeArea.rightAnchor, constant: 0).isActive = true
        inputContainerBottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        inputContainerBottomConstraint?.isActive = true
        inputContainer.anchorViewWithHeightConstant(height: 70)
        
        inputContainer.addSubview(inputDivider)
        inputContainer.addSubview(uploadImageButton)
        inputContainer.addSubview(inputTextField)
        inputContainer.addSubview(sendButton)
        
        //input divider
        inputDivider.anchorViewTo(top: inputContainer.topAnchor, left: inputContainer.leftAnchor, bottom: nil, right: inputContainer.rightAnchor)
        inputDivider.anchorViewWithHeightConstant(height: 0.5)
        
        //upload image button
        uploadImageButton.anchorViewWithConstantsTo(top: inputContainer.topAnchor, left: inputContainer.leftAnchor, bottom: nil, right: nil, topConstant: 0.5, leftConstant: 6, bottomConstant: 0, rightConstant: 0)
        uploadImageButton.anchorViewWithHeightAndWidthConstant(height: 44, width: 44)
        
        //send button
        sendButton.anchorViewWithConstantsTo(top: inputContainer.topAnchor, left: nil, bottom: inputContainer.bottomAnchor, right: inputContainer.rightAnchor, topConstant: 0.5, leftConstant: 0, bottomConstant: 20, rightConstant: 0)
        sendButton.anchorViewWithWidthConstant(width: 80)
        
        //input textfield
        inputTextField.anchorViewWithConstantsTo(top: inputContainer.topAnchor, left: uploadImageButton.rightAnchor, bottom: inputContainer.bottomAnchor, right: sendButton.leftAnchor, topConstant: 0.5, leftConstant: 6, bottomConstant: 20, rightConstant: 0)
    }
    
    private func getMessageEstimatedFrame(text: String) -> CGRect {
        let size = CGSize(width: 250, height: 1000)
        return NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    private func loadMessages() {
        FirebaseService.shared.loadChatLogMessages(toUser: toUser) { (message) in
            self.messages.append(message)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.scrollToLastMessage()
            }
        }
    }
    
    private func scrollToLastMessageWithAnimation() {
        if self.messages.count <= 0 { return }
        let lastIndexPath = IndexPath(item: self.messages.count - 1, section: 0)
        self.collectionView.scrollToItem(at: lastIndexPath, at: .top, animated: true)
    }
    
    private func scrollToLastMessage() {
        if self.messages.count <= 0 { return }
        let lastIndexPath = IndexPath(item: self.messages.count - 1, section: 0)
        self.collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: false)
    }
    
    private func sendMessage() {
        guard let text = inputTextField.text else { return }
        if text.count <= 0 { return }
        FirebaseService.shared.sendMessage(toUser: toUser, text: text)
        inputTextField.text = nil
    }
    
    private func sendImage() {
        showImagePickerController()
    }
    
    //MARK: Datasource and delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatLogCollectionCell", for: indexPath) as! ChatLogCollectionCell
        let message = messages[indexPath.item]
        cell.message = message
        
        if message.messageMedia != nil {
            cell.widthConstant = 250
        }
        else {
            if let text = message.text {
                cell.widthConstant = getMessageEstimatedFrame(text: text).width + 32
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let message = messages[indexPath.item]
        var height: CGFloat = 0
        
        if let imageWidth = message.messageMedia?.imageWidth, let imageHeight = message.messageMedia?.imageHeight {
            height = imageHeight / imageWidth * 250
        }
        else {
            if let text = message.text {
                height = getMessageEstimatedFrame(text: text).height + 16
            }
            else {
                height = 0
            }
        }

        return CGSize(width: view.frame.width, height: height)
    }
}







































