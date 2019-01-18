//
//  LoginViewController.swift
//  FirebaseChatApp
//
//  Created by Ong Wei Yap on 13/1/19.
//  Copyright © 2019 Ong Wei Yap. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    //MARK: UI
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 60
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectImage)))
        return imageView
    }()
    
    lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.tintColor = .white
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        return sc
    }()
    
    let inputStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "name"
        return textField
    }()
    
    let divider1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        return view
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        return textField
    }()
    
    let divider2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        return view
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.placeholder = "Password"
        return textField
    }()
    
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.rgb(red: 80, green: 101, blue: 161)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(registerButtonPressed), for: .touchUpInside)
        return button
    }()
    
    let nameView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let emailView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let passwordView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    //MARK: Variables
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private var inputStackViewHeightConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rgb(red: 61, green: 91, blue: 151)
        
        createInputStackView()
    }
    
    //MARK: Objc func
    @objc private func segmentedControlChanged() {
        let selectedIndex = segmentedControl.selectedSegmentIndex
        let title = segmentedControl.titleForSegment(at: selectedIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        inputStackViewHeightConstraint?.constant = selectedIndex == 0 ? 100 : 150
        
        UIView.animate(withDuration: 0.3, animations: {
            if selectedIndex == 0 {
                self.nameView.isHidden = true
            }
            else {
                self.nameView.isHidden = false
            }
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func registerButtonPressed() {
        if segmentedControl.selectedSegmentIndex == 0 {
            login()
        }
        else {
            register()
        }
    }
    
    @objc private func selectImage() {
        loadImages()
    }
    
    //MARK: Private func
    private func createInputStackView() {
        
        view.addSubview(profileImageView)
        view.addSubview(segmentedControl)
        view.addSubview(inputStackView)
        view.addSubview(loginRegisterButton)
        
        //Profile imageview
        profileImageView.anchorViewWithConstantsTo(top: nil, left: nil, bottom: segmentedControl.topAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 12, rightConstant: 0)
        profileImageView.centerViewWithX(x: view.centerXAnchor)
        profileImageView.anchorViewWithHeightAndWidthConstant(height: 120, width: 120)

        //Segmented Control
        segmentedControl.anchorViewWithConstantsTo(top: nil, left: nil, bottom: inputStackView.topAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 12, rightConstant: 0)
        segmentedControl.centerViewWithX(x: view.centerXAnchor)
        segmentedControl.anchorViewWithWidthAnchorAndConstant(width: inputStackView.widthAnchor, widthConstant: 0)
        segmentedControl.anchorViewWithHeightConstant(height: 40)
        
        //Nameview
        nameView.addSubview(nameTextField)
        nameTextField.anchorViewWithConstantsTo(top: nameView.topAnchor, left: nameView.leftAnchor, bottom: nameView.bottomAnchor, right: nameView.rightAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 0.5, rightConstant: 12)
        nameView.addSubview(divider1)
        divider1.anchorViewWithConstantsTo(top: nameTextField.bottomAnchor, left: nameView.leftAnchor, bottom: nil, right: nameView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        divider1.anchorViewWithHeightConstant(height: 0.5)
        nameView.isHidden = true
        
        //Emailview
        emailView.addSubview(emailTextField)
        emailTextField.anchorViewWithConstantsTo(top: emailView.topAnchor, left: emailView.leftAnchor, bottom: emailView.bottomAnchor, right: emailView.rightAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 0.5, rightConstant: 12)
        emailView.addSubview(divider2)
        divider2.anchorViewWithConstantsTo(top: emailTextField.bottomAnchor, left: emailView.leftAnchor, bottom: nil, right: emailView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        divider2.anchorViewWithHeightConstant(height: 0.5)
        
        //Passwordview
        passwordView.addSubview(passwordTextField)
        passwordTextField.anchorViewWithConstantsTo(top: passwordView.topAnchor, left: passwordView.leftAnchor, bottom: passwordView.bottomAnchor, right: passwordView.rightAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 12)
        
        //Input stackview
        inputStackView.addArrangedSubview(nameView)
        inputStackView.addArrangedSubview(emailView)
        inputStackView.addArrangedSubview(passwordView)
        inputStackView.centerViewWithXandY(x: view.centerXAnchor, y: view.centerYAnchor)
        inputStackView.anchorViewWithWidthAnchorAndConstant(width: view.widthAnchor, widthConstant: -24)
        inputStackViewHeightConstraint = inputStackView.heightAnchor.constraint(equalToConstant: 100)
        inputStackViewHeightConstraint?.isActive = true
        
        //Login button
        loginRegisterButton.anchorViewWithConstantsTo(top: inputStackView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 12, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        loginRegisterButton.centerViewWithX(x: view.centerXAnchor)
        loginRegisterButton.anchorViewWithWidthAnchorAndConstant(width: inputStackView.widthAnchor, widthConstant: 0)
        loginRegisterButton.anchorViewWithHeightConstant(height: 50)
    }
    
    private func register() {
        guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        FirebaseService.shared.registerUserWithEmail(email: email, password: password) { (user, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            
            guard let registeredUser = user else { return }
            
            if let profileImage = self.profileImageView.image, let imageData = UIImageJPEGRepresentation(profileImage, 0.1) { //User did upload image
                FirebaseService.shared.uploadImage(imageData: imageData, isMessageImage: false, completion: { (urlString) in
                    
                    if urlString != nil {
                        self.updateUser(uid: registeredUser.uid, name: name, email: email, profileImageUrl: urlString)
                    }
                    
                })
            }
            else { //User did not upload image
                self.updateUser(uid: registeredUser.uid, name: name, email: email, profileImageUrl: nil)
            }
        
        }
    }
    
    private func updateUser(uid: String, name: String, email: String, profileImageUrl: String?) {
        FirebaseService.shared.updateUserToDatabase(uid: uid, name: name, email: email, profileImageUrl: profileImageUrl, completion: { (error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    private func login() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        FirebaseService.shared.loginUserWithEmail(email: email, password: password) { (user, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
 
}

































