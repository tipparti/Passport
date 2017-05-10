//
//  TableViewCell.swift
//  Passport
//
//  Created by Naina Sai Tipparti on 5/9/17.
//  Copyright © 2017 Naina Sai Tipparti. All rights reserved.
//

import Foundation


protocol TableViewCellDelegate {
    
    // Indicates that the edit process has begun for the given cell
    func cellDidBeginEditing(editingCell: TableViewCell)
    // Indicates that the edit process has committed for the given cell
    func cellDidEndEditing(editingCell: TableViewCell)
}

import UIKit

class TableViewCell: UITableViewCell, UITextFieldDelegate {
    
    let label:UITextField
    
    var listName:User? {
        didSet{
            label.text = listName?.name
        }
    }

    var listAge:User? {
        didSet{
            label.text = listAge?.age
        }
    }
    
    
    var delegate: TableViewCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        // 1
        label = UITextField(frame: CGRect.null)
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 16)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // 2
        label.delegate = self
        label.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        // 3
        addSubview(label)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let leftMarginForLabel: CGFloat = 15.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: leftMarginForLabel, y: 0, width: bounds.size.width - leftMarginForLabel, height: bounds.size.height)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if listName != nil {
            self.listName!.name = textField.text!
        }
        if listAge != nil {
            self.listAge!.age = textField.text!
        }
        if delegate != nil {
            delegate?.cellDidEndEditing(editingCell: self)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if delegate != nil {
            delegate!.cellDidBeginEditing(editingCell: self)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
