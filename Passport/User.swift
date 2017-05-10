//
//  User.swift
//  Passport
//
//  Created by Naina Sai Tipparti on 5/4/17.
//  Copyright © 2017 Naina Sai Tipparti. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var id: Int?
    var name: String?
    var email: String?
    var profileImageUrl: String?
    var age: String?
    var hobbies: [String]?
    var color: String?
    var gender: String?
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? Int
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
        self.age = dictionary["age"] as? String
        self.hobbies = dictionary["hobbies"] as? [String]
        self.color = dictionary["color"] as? String
        self.gender = dictionary["gender"] as? String
    }
    
}
