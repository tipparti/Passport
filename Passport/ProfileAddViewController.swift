//
//  ProfileAddViewController.swift
//  Passport
//
//  Created by Naina Sai Tipparti on 5/4/17.
//  Copyright © 2017 Naina Sai Tipparti. All rights reserved.
//

import UIKit
import Firebase
import WSTagsField

class ProfileAddViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    
    var users = [User]()
        
    var count: Int!
    
    var hobbiesArray: [String]! = [String]()
    
    var userController: UsersController?
    
    var scrollView: UIScrollView!
    

    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Add", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        
        return button
    }()
    
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            //successfully logged in our user
            self.dismiss(animated: true, completion: nil)
            
        })
        
    }
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.keyboardType = UIKeyboardType.emailAddress
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let ageTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Age"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let ageSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let passwordSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "gameofthrones_splash")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    lazy var genderSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Male", "Female"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        return sc
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(genderSegmentedControl)

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationController?.navigationBar.layer.backgroundColor = UIColor(r: 61, g: 91, b: 151).cgColor
//        navigationController?.navigationBar.barStyle = UIBarStyle.default 
        navigationController?.navigationBar.isTranslucent = false
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        ageTextField.delegate = self
        passwordTextField.delegate = self
        view.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
        
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
        setupGenderSegmentedControl()
        fetchUser()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if( textField == self.nameTextField ){
            
           nameTextField.resignFirstResponder()
           emailTextField.becomeFirstResponder()
        
        } else if( textField == self.emailTextField ) {
            
           emailTextField.resignFirstResponder()
           passwordTextField.becomeFirstResponder()
            
        } else if( textField == self.passwordTextField ) {
            
            passwordTextField.resignFirstResponder()
            ageTextField.becomeFirstResponder()
            
        } else if( textField == self.ageTextField ) {
            
            ageTextField.resignFirstResponder()
            hobbiesTextField.becomeFirstResponder()
            
        }
        
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 64.0  {
                self.view.frame.origin.y -= keyboardSize.height / 1.35
            } else {
                self.view.frame.origin.y = 72.0
                self.view.frame.origin.y -= keyboardSize.height

            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 64.0 {
                self.view.frame.origin.y = 64.0
            } else if self.view.frame.origin.y == keyboardSize.height / 1.35 {
             
                self.view.frame.origin.y += keyboardSize.height
                
            }
        }
    }
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    
    func setupGenderSegmentedControl() {
        //need x, y, width, height constraints
        genderSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        genderSegmentedControl.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        genderSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1).isActive = true
        genderSegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    func setupProfileImageView() {
        //need x, y, width, height constraints
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
    }
    

    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    var genderSegementAnchor: NSLayoutConstraint?
    var ageTextFieldHeightAnchor: NSLayoutConstraint?
    var hobbiesTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputsContainerView() {
        //need x, y, width, height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 250)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        inputsContainerView.addSubview(passwordSeparatorView)
        inputsContainerView.addSubview(ageTextField)
        inputsContainerView.addSubview(ageSeparatorView)
        inputsContainerView.addSubview(hobbiesTextField)
        inputsContainerView.addSubview(hobbiesSeparatorView)
        
        //need x, y, width, height constraints
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5)
        nameTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5)
        
        emailTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5)
        passwordTextFieldHeightAnchor?.isActive = true
        
        
        //need x, y, width, height constraints
        passwordSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        passwordSeparatorView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        passwordSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        //need x, y, width, height constraints
        ageTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        ageTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        
        ageTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        ageTextFieldHeightAnchor = ageTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5)
        ageTextFieldHeightAnchor?.isActive = true
        
        
        //need x, y, width, height constraints
        ageSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        ageSeparatorView.topAnchor.constraint(equalTo: ageTextField.bottomAnchor).isActive = true
        ageSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        ageSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        //need x, y, width, height constraints
        hobbiesTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 4).isActive = true
        hobbiesTextField.topAnchor.constraint(equalTo: ageTextField.bottomAnchor).isActive = true
        hobbiesTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        hobbiesTextFieldHeightAnchor = hobbiesTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5)
        hobbiesTextFieldHeightAnchor?.isActive = true
        
        
        //need x, y, width, height constraints
        hobbiesSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        hobbiesSeparatorView.topAnchor.constraint(equalTo: hobbiesTextField.bottomAnchor).isActive = true
        hobbiesSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        hobbiesSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }

    
    
    func setupLoginRegisterButton() {
        //need x, y, width, height constraints
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: genderSegmentedControl.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
}


