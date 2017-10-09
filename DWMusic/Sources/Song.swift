//
//  Song.swift
//  WeiPlayer
//
//  Created by BmMac on 2017/8/28.
//  Copyright © 2017年 wei. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Song : Decodable {
    var name:String?
    var user:String?
    var url:String?
    var cover:String?
    var lrc:String?
    
    init(_ json: JSON) {
        name = json["name"].stringValue
        user = json["user"].stringValue
        url = json["url"].stringValue
        cover = json["cover"].stringValue
        lrc = json["lrc"].stringValue
    }
}
