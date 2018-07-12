//
//  TablePickerTableViewCell.swift
//  IMEPayWallet
//
//  Created by admin on 6/8/18.
//  Copyright © 2018 imedigital. All rights reserved.
//

import UIKit

class TablePickerTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var checkImageView: UIImageView!
    
    var selectedPlace: String?
    var title: String?
    
    @IBOutlet weak var backgroundview: UIView!
    
    func setup() {
        self.avatarButton.rounded()
        self.backgroundview.layer.cornerRadius = 8.0
        self.titleLabel.text = title
        if let character = title?.first {
            self.avatarButton.setTitle("\(character)", for: .normal)
        }
        selectedPlace?.lowercased() == title?.lowercased() ? (self.checkImageView.isHidden = false) : (self.checkImageView.isHidden = true)
    }
}
