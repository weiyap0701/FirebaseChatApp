//
//  HomeCollectionController.swift
//  FirebaseChatApp
//
//  Created by Ong Wei Yap on 13/1/19.
//  Copyright © 2019 Ong Wei Yap. All rights reserved.
//

import Foundation
import UIKit

class HomeTableController: UITableViewController {
    
    //MARK: Variables
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        createNavBar()
        createTableView()
        loadMessages()
        checkIfLogin()
    }
    
    //MARK: Objc func
    @objc private func logoutButtonPressed() {
        FirebaseService.shared.signOut()
        let loginVc = LoginViewController()
        present(loginVc, animated: true, completion: nil)
    }
    
    @objc private func newMessageButtonPressed() {
        let newMessageController = NewMessageTableController()
        present(UINavigationController(rootViewController: newMessageController), animated: true, completion: nil)
    }
    
    @objc private func performReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return message1.timestamp! > message2.timestamp!
        })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    //MARK: Private func
    private func createNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonPressed))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "editIcon1"), style: .plain, target: self, action: #selector(newMessageButtonPressed))
    }
    
    private func createTableView() {
        tableView.register(HomeTableCell.self, forCellReuseIdentifier: "HomeTableCell")
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.tableFooterView = UIView()
    }
    
    private func checkIfLogin() {
        if !FirebaseService.shared.isLoggedIn() {
            perform(#selector(logoutButtonPressed), with: nil, afterDelay: 0)
        }
        else {
            FirebaseService.shared.getUserInfo { (user) in
                self.navigationItem.title = user.name
            }
        }
    }
    
    private func loadMessages() {
        FirebaseService.shared.loadHomeMessages { (message) in
            if let toUserId = message.toUser?.userId, let fromUserId = message.fromUser?.userId {
                
                var dicKey = ""
                if message.isReceiver {
                    dicKey = fromUserId + toUserId
                }
                else {
                    dicKey = toUserId + fromUserId
                }
                
                self.messagesDictionary[dicKey] = message
                
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.performReloadTable), userInfo: nil, repeats: false)
            }
        }
    }
    
    //MARK: Datasource and Delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableCell", for: indexPath) as! HomeTableCell
        cell.message = messages[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var toUser: UserModel!
        let message = messages[indexPath.row]
        if message.isReceiver {
            toUser = message.fromUser
        }
        else {
            toUser = message.toUser
        }
        
        let vc = ChatLogViewController()
        vc.toUser = toUser
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let message = messages[indexPath.row]
            FirebaseService.shared.deleteHomeMessage(message: message) { (error, partnerId) in
                if error == nil {
                    if let id1 = partnerId, let id2 = UserModel.decode()?.userId {
                        let key = id1 + id2
                        self.messagesDictionary.removeValue(forKey: key)
                        self.performReloadTable()
                    }
                }
            }
            
        }
    }
}

















