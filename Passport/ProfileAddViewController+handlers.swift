//
//  ProfileAddViewController+handlers.swift
//  Passport
//
//  Created by Naina Sai Tipparti on 5/4/17.
//  Copyright © 2017 Naina Sai Tipparti. All rights reserved.
//

import UIKit
import Firebase

extension ProfileAddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    

    func fetchUser() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                self.users.append(user)
                
            }
            
        }, withCancel: nil)
    }
    
    func handleRegister() {
    
        var gender: String?
                
        if  hobbiesTextField.tags.count != 0 {
            
            for i in 0..<hobbiesTextField.tags.count{
                
                self.hobbiesArray?.append(hobbiesTextField.tags[i].text)
            }
            
        }
        
        if (self.emailTextField.text?.isEmpty == true) {
            self.emailSeparatorView.layer.borderColor = UIColor.red.cgColor
            self.emailSeparatorView.layer.borderWidth = 1.0
        }
        if (self.passwordTextField.text?.isEmpty == true) {
            self.passwordSeparatorView.layer.borderColor = UIColor.red.cgColor
            self.passwordSeparatorView.layer.borderWidth = 1.0
        }
        if (self.nameTextField.text?.isEmpty == true) {
            self.nameSeparatorView.layer.borderColor = UIColor.red.cgColor
            self.nameSeparatorView.layer.borderWidth = 1.0
        }
        if (self.ageTextField.text?.isEmpty == true) {
            self.ageSeparatorView.layer.borderColor = UIColor.red.cgColor
            self.ageSeparatorView.layer.borderWidth = 1.0
        }
        
        if genderSegmentedControl.selectedSegmentIndex == -1 {
            
            self.genderSegmentedControl.layer.borderColor = UIColor.red.cgColor
            self.genderSegmentedControl.layer.borderWidth = 1.0
       
        } else {
            
            gender = genderSegmentedControl.titleForSegment(at: genderSegmentedControl.selectedSegmentIndex)
        
        }

        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text, let age = ageTextField.text  else {
            print("Form is not valid")
            return
        }
       
        
        count = users.count
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            let color: String!
            
            if (gender == "Male"){
                
                color = "blue"
                
            }else {
                
                color = "green"
            }
            
            
            //successfully authenticated user
            let imageName = UUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).png")
            
            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {
                
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                                            
                        

                        let values: [String: Any]! = ["name": name, "email": email, "id":self.count, "color":color, "gender": gender ?? "", "age": age, "profileImageUrl": profileImageUrl, "hobbies": self.hobbiesArray]
                        
                        
                        self.registerUserIntoDatabaseWithUID(uid, values: values as [String : Any])
                    }
                })
            }
        })
    }
    
    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: Any]) {
        let ref = FIRDatabase.database().reference(fromURL: "https://profile-6ca2b.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if let err = err {
                print(err)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
}
