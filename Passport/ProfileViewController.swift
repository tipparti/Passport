//
//  ProfileViewController.swift
//  Passport
//
//  Created by Naina Sai Tipparti on 5/7/17.
//  Copyright © 2017 Naina Sai Tipparti. All rights reserved.
//

import UIKit
import WSTagsField
import ChameleonFramework
import MBProgressHUD

var detailProfile = [User]()
var keyProfile = [UserKey]()


class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    let cellId = "cellId"
    var imagePickerString: String! = ""
    
    var houseImage: UIImage!
    
    var hobbieArray: [String]! = [String]()
    
    var colors: [String] = ["Select", "FlatSkyBlue", "FlatTeal", "RandomFlatColor"]
    
    var cellColor: UIColor!
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = FlatWhite().cgColor
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    
    lazy var bannerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false
        
        return imageView
    }()
    
    let hobbiesTextField: WSTagsField = {
        
        let tagsField =  WSTagsField()
        tagsField.spaceBetweenTags = 10.0
        tagsField.selectedColor = .red
        tagsField.selectedTextColor = .white
        tagsField.placeholder = "Hobbies"
        tagsField.translatesAutoresizingMaskIntoConstraints = false
        return tagsField
    }()
    
    let hobbiesSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        return tv
    }()
    
    lazy var pickerView: UIPickerView = {
        let pv = UIPickerView()
        pv.translatesAutoresizingMaskIntoConstraints = false
        return pv
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleUpdate))
        navigationController?.navigationBar.layer.backgroundColor = UIColor(r: 61, g: 91, b: 151).cgColor
        navigationController?.navigationBar.isTranslucent = false
        
        
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: cellId)


        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        
        tableView.dataSource = self
        tableView.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        
        getUser()

        view.addSubview(bannerImageView)
        view.addSubview(profileImageView)
        view.addSubview(tableView)
        view.addSubview(hobbiesTextField)
        view.addSubview(pickerView)

        setupProfileImageView()
        setupTableView()
        setupHobbTextField()
        setupPickerView()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func getUser(){
        
        guard detailProfile.count != 0 else {
            
            print("No data")
            return
        }
        
        var houseName: NSString!
        
        
        for each in detailProfile {
            
            profileImageView.loadImageUsingCacheWithUrlString(each.profileImageUrl!)
            houseName = each.name! as NSString
            
        }
        
        if(houseName.lowercased.range(of: "lannister") != nil){
            bannerImageView.image = scaledImage(UIImage(named:"lannister-sigil")!, maximumWidth: UIScreen.main.bounds.width)
        }else if(houseName.lowercased.range(of: "targaryen") != nil) {
            bannerImageView.image = scaledImage(UIImage(named:"targaryen-sigil")!, maximumWidth: UIScreen.main.bounds.width)
        }else if(houseName.lowercased.range(of: "stark") != nil){
            bannerImageView.image = scaledImage(UIImage(named:"stark-sigil")!, maximumWidth: UIScreen.main.bounds.width)
        }else {
            bannerImageView.image = scaledImage(UIImage(named:"got")!, maximumWidth: UIScreen.main.bounds.width)
        }
        
        
    }
    
    func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        imagePickerString = "Profile"
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
            
            switch imagePickerString {
            case "Profile":
                 profileImageView.image = selectedImage
            default:
                break
            }
        
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }

    
    func setupProfileImageView() {
        
        //need x, y, width, height constraints
        profileImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
    func setupBannerImageView() {
        //need x, y, width, height constraints
        
        bannerImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -4).isActive = true
        bannerImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: -8).isActive = true
        bannerImageView.heightAnchor.constraint(equalToConstant: 95).isActive = true
        bannerImageView.image = scaledImage(bannerImageView.image!, maximumWidth: UIScreen.main.bounds.width)
        bannerImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        
    }
    
    func setupHobbTextField(){
         //need x, y, width, height constraints
        
        hobbiesTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        hobbiesTextField.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -16).isActive = true
        hobbiesTextField.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        
    }
    
    func setupPickerView() {
        //need x, y, width, height constraints
        
        pickerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        pickerView.topAnchor.constraint(equalTo: hobbiesTextField.bottomAnchor, constant: -24).isActive = true
        pickerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
    }

    
    func scaledImage(_ image: UIImage, maximumWidth: CGFloat) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let cgImage: CGImage = image.cgImage!.cropping(to: rect)!
        return UIImage(cgImage: cgImage, scale: image.size.width / maximumWidth, orientation: image.imageOrientation)
        
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
