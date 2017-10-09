//
//  TableViewCell.swift
//  LrcTableView
//
//  Created by mac3 on 2017/9/22.
//  Copyright © 2017年 mac3. All rights reserved.
//

import UIKit
import SwifterSwift

class LrcLabel: UILabel {
    var progress: CGFloat = 0.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        UIColor(hex: 0x6F2EB1)!.set()
        let fillRect = CGRect(x: 0, y: 0, width: progress*rect.width, height: rect.height)
        UIRectFillUsingBlendMode(fillRect, CGBlendMode.sourceIn)
    }
}

class TableViewCell: UITableViewCell {

    @IBOutlet weak var lrcLabel: LrcLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    var data: LrcData? {
        willSet {
            lrcLabel.text = "\((newValue?.text)!)"
            progress = 0.0
        }
    }
    
    var progress: TimeInterval = 0.0 {
        willSet {
            if let data = data {
                self.lrcLabel.progress = CGFloat(data.getPregress(newValue))
            }
        }
    }
}
