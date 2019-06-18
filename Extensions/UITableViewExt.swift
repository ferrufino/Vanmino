//
//  UITableViewExt.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-03-30.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//

import UIKit

extension UITableView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "Avenir Black", size: 25)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .none
    }
    
    
}

extension UITableViewCell {
    func assignDiff(diff: Int) -> String{
        switch diff {
        case 0:
            return "Easy"
        case 1:
            return "Intermediate"
        case 2:
            return "Expert"
        default:
            return "Not defined"
        }
    }
}

