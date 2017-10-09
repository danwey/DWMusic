//
//  tools.swift
//  rxtableview
//
//  Created by mac3 on 2017/9/29.
//  Copyright © 2017年 wei. All rights reserved.
//

import Foundation

//转换时间
extension TimeInterval {
    
    func toTimeString () -> String {
        let min = Int(self) / 60
        let sec = Int(self) % 60
        return String(format:"%02d:%02d",min,sec)
    }
    
}
