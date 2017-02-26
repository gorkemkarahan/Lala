///
//  GKTextView.swift
//  Lala
//
//  Created by Görkem Karahan on 23/02/2017.
//  Copyright © 2017 Migros. All rights reserved.
//

import UIKit

class GKTextView: UITextView {
    
    override var bounds: CGRect {
        didSet{
            if self.contentSize.height <= self.bounds.size.height + 1
            {
                self.contentOffset = CGPoint(x: 0, y: 0)
            }
        }
    }
}
