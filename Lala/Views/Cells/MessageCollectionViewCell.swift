//
//  MessageCollectionViewCell.swift
//  Lala
//
//  Created by Görkem Karahan on 21/02/2017.
//  Copyright © 2017 Görkem Karahan. All rights reserved.
//

import UIKit
import Kingfisher

class MessageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgVAvatar: UIImageView!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblNickname: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    
    func preparefor(message:Message) {
        self.lblNickname.text = message.user.nickname
        self.lblDateTime.text = message.messageDateTime
        self.lblMessage.text = message.text
        self.imgVAvatar.kf.setImage(with: URL(string: message.user.avatarUrl))
    }
}
