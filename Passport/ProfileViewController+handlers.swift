//
//  ProfileViewController+handlers.swift
//  Passport
//
//  Created by Naina Sai Tipparti on 5/8/17.
//  Copyright © 2017 Naina Sai Tipparti. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework
import Firebase
import WSTagsField
import MBProgressHUD

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate, TableViewCellDelegate {
    

     func handleUpdate(){
        
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Updating"
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        if  hobbiesTextField.tags.count != 0 {
            
            for i in 0..<hobbiesTextField.tags.count{
                
                hobbieArray?.append(hobbiesTextField.tags[i].text)
            }
            
        }

        
        let imageName = UUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).png")
        
        if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {
            
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if let error = error {
                    print(error)
                    return
                }
                
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    
                    
                    
                    let values: [String: Any]! = ["name": detailProfile[0].name ?? "", "profileImageUrl": profileImageUrl, "hobbies": self.hobbieArray]
                    
                    
                    self.registerUserIntoDatabaseWithUID(((keyProfile[0].userKey)!), values: values as [String : Any])
                }
            })
        }
    }
    
    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: Any]) {
        let ref = FIRDatabase.database().reference(fromURL: "https://profile-6ca2b.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if let err = err {
                print(err)
                return
            }
            MBProgressHUD.hide(for: self.view, animated: true)
            self.dismiss(animated: true, completion: nil)
        })
    }

    
    
    func numberOfSections(in tableView: UITableView) -> Int{
        
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TableViewCell

        switch indexPath.section {
        case 0:
            let list = detailProfile[indexPath.row]
            cell.listName = list
            cell.delegate = self
            break
        case 1:
            let list = detailProfile[indexPath.row]
            cell.listAge = list
            cell.delegate = self
            break
        case 2:
            cell.textLabel?.text = detailProfile[indexPath.row].gender
            cell.isUserInteractionEnabled = false
            break
        default:
            break
            
            
        }
        if cellColor != nil {
            cell.backgroundColor = self.cellColor
        }
        self.hobbiesTextField.addTags(detailProfile[indexPath.row].hobbies!)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    
    }
    
    
    
    
    func setupTableView() {
        
        tableView.isScrollEnabled = false
        tableView.allowsSelectionDuringEditing = true
        tableView.allowsMultipleSelection = false
        tableView.allowsSelectionDuringEditing = false
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        //need x, y, width, height constraints
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tableView.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor, constant: 0).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 175).isActive = true
        tableView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        
    }
    
    func cellDidBeginEditing(editingCell: TableViewCell) {
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        for cell in visibleCells {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                if cell != editingCell {
                    cell.alpha = 0.3
                }
            })
        }
        
        
    }
    
    func cellDidEndEditing(editingCell: TableViewCell) {
        
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        let lastView = visibleCells[visibleCells.count - 1] as TableViewCell
        for cell: TableViewCell in visibleCells {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                if cell != editingCell {
                    cell.alpha = 1.0
                }
            }, completion: { (Finished: Bool) -> Void in
                if cell == lastView {
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    
}

extension ProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colors.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return colors[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        var color: UIColor!
        
        switch colors[row] {
        case "FlatTeal":
            color = FlatTeal()
            self.cellColor = FlatTeal()
            
        case "FlatSkyBlue":
            color = FlatSkyBlue()
            self.cellColor = FlatSkyBlue()
        case "RandomFlatColor":
            color = RandomFlatColor()
            self.cellColor = color
        default:
            color = FlatWhite()
            self.cellColor = FlatWhite()
            
        }
        
        DispatchQueue.main.async {
            self.view.backgroundColor = color
            self.tableView.backgroundColor = color
            self.tableView.reloadData()
        }
        
        
    }


}
