//
//  UsersController.swift
//  Passport
//
//  Created by Naina Sai Tipparti on 5/4/17.
//  Copyright © 2017 Naina Sai Tipparti. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class UsersController: UITableViewController {
    
    
    let cellId = "cellId"
    
    var users = [User]()
    
    var usersKey = [UserKey]()
    
    var deleteUserIndexPath: NSIndexPath? = nil

    
    var cnt: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleNewUser))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"Filter-22"), style: .plain, target: self, action: #selector(showActionSheet))

        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.isUserInteractionEnabled = true
        
        fetchUser()
    }
    
    func fetchUser() {
        
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            
            let key = UserKey(key: snapshot.key)
            self.usersKey.append(key)
            
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                self.users.append(user)

                //this will crash because of background thread, so lets use dispatch_async to fix
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                    self.cnt = self.users.count
                })
            }
            
        }, withCancel: nil)
        

    }

    
    func handleNewUser() {
        let userController = ProfileAddViewController()
        let navController = UINavigationController(rootViewController: userController)
        present(navController, animated: true, completion: nil)
    }
    
    func handleSortUser(){
        
        self.users.sort(by: {$0.id! < $1.id!})
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    
    }
    
    func handleSortNameAge(type: String?){
        
        switch type! {
        case "NameAES":
            self.users.sort(by: {$0.name! < $1.name!})
            break
        case "NameDES":
            self.users.sort(by: {$0.name! > $1.name!})
            break
        case "AgeAES":
            self.users.sort(by: {$0.age! < $1.age!})
            break
        case "AgeDES":
            self.users.sort(by: {$0.age! > $1.age!})
            break
        default:
            break
        }
        
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
        
    }
    
    
    func filterGender(key: String?){
        
        users.removeAll()
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                self.users.append(user)
                
                
                //this will crash because of background thread, so lets use dispatch_async to fix
                DispatchQueue.main.async(execute: {
                    self.users = self.users.filter {
                        $0.gender! == key! as String
                    }
                    self.tableView.reloadData()
                })
            }
            
        }, withCancel: nil)
            
        

    }
    
    
    func showActionSheet() {

        let optionMenu = UIAlertController(title: nil, message: "Filter", preferredStyle: .actionSheet)
        
        let orderSheet = UIAlertController(title: nil, message: "Order", preferredStyle: .actionSheet)

        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.dismiss(animated: true, completion: nil)
            
        })
        
        let maleAction = UIAlertAction(title: "Show Male Profiles", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.filterGender(key: "Male")
            
        })
        let femaleAction = UIAlertAction(title: "Show Female Profiles", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.filterGender(key: "Female")
            
        })
        
        
        let ageAction = UIAlertAction(title: "Sort By Age", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            let orderAesAction = UIAlertAction(title: "Ascending", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                
                self.handleSortNameAge(type: "AgeAES")
            })
            
            let orderDesAction = UIAlertAction(title: "Descending", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                
                self.handleSortNameAge(type: "AgeDES")
            })
            
            orderSheet.addAction(orderAesAction)
            orderSheet.addAction(orderDesAction)
            orderSheet.addAction(cancelAction)
            
            self.present(orderSheet, animated: true, completion: nil)
            
        })
        
        let nameAction = UIAlertAction(title: "Sort By Name", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            
            let orderAesAction = UIAlertAction(title: "Ascending", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                
                self.handleSortNameAge(type: "NameAES")
            })
            
            let orderDesAction = UIAlertAction(title: "Descending", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                
                self.handleSortNameAge(type: "NameDES")
            })
            
            orderSheet.addAction(orderAesAction)
            orderSheet.addAction(orderDesAction)
            orderSheet.addAction(cancelAction)

           self.present(orderSheet, animated: true, completion: nil)

        })
        
        let clearAction = UIAlertAction(title: "Reset", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.users.removeAll()
            self.fetchUser()
        })
        
        optionMenu.addAction(nameAction)
        optionMenu.addAction(ageAction)
        optionMenu.addAction(maleAction)
        optionMenu.addAction(femaleAction)
        optionMenu.addAction(clearAction)
        optionMenu.addAction(cancelAction)
        
        present(optionMenu, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let profileController = ProfileViewController()
        detailProfile = [users[indexPath.row]]
        keyProfile = [usersKey[indexPath.row]]
        let navController = UINavigationController(rootViewController: profileController)
        
        present(navController, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        let gender = user.gender
        
        if (gender == "Male") {
            cell.backgroundColor = FlatSkyBlue()
        }else{
            cell.backgroundColor = FlatMint()
        }
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            deleteUserIndexPath = indexPath as NSIndexPath
            confirmDelete()
        }

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func confirmDelete(){
        
        let alert = UIAlertController(title: "Delete User", message: "Are you sure you want to permanently delete?", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteUser)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteUser)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)

        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func handleDeleteUser(alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteUserIndexPath {
            
            tableView.beginUpdates()
            
            users.remove(at: indexPath.row)
            
            // Note that indexPath is wrapped in an array:  [indexPath]
            tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
            let uid = usersKey[indexPath.row].userKey
            let ref =  FIRDatabase.database().reference()
            let usersReference = ref.child("users").child(uid!)
            
            usersReference.removeValue(completionBlock: { (error, refer) in
                if error != nil {
                    print(error ?? "")
                } else {
                    print(refer)
                    print("Child Removed Correctly")
                }
            })
            
            deleteUserIndexPath = nil
            
            tableView.endUpdates()
        }
    }
    
    func cancelDeleteUser(alertAction: UIAlertAction!) {
        deleteUserIndexPath = nil
    }
    
}

class UserCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
