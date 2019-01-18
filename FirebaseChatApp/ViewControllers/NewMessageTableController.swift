//
//  NewMessageTableController.swift
//  FirebaseChatApp
//
//  Created by Ong Wei Yap on 14/1/19.
//  Copyright © 2019 Ong Wei Yap. All rights reserved.
//

import Foundation
import UIKit

class NewMessageTableController: UITableViewController {
    
    //MARK: Variables
    var users = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTableView()
        createNavBar()
        loadUsers()
    }
    
    //MARK: Objc func
    @objc private func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Private func
    private func createNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonPressed))
    }
    
    private func createTableView() {
        tableView.register(NewMessageTableCell.self, forCellReuseIdentifier: "NewMessageTableCell")
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }
    
    private func loadUsers() {
        FirebaseService.shared.getUserList { (user) in
            if user.userId != UserModel.decode()?.userId {
                self.users.append(user)
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: Datasource and delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewMessageTableCell", for: indexPath) as! NewMessageTableCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ChatLogViewController()
        vc.toUser = users[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}










































