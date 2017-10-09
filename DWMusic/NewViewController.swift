//
//  NewViewController.swift
//  DWMusic
//
//  Created by mac3 on 2017/10/9.
//  Copyright © 2017年 mac3. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON

open class NewViewController: UIViewController {

    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData//不要缓存
        
        URLSession(configuration: config).dataTask(with: URL.init(string: "http://192.168.30.77:8080/api/musicList.json")!, completionHandler: { (data, response, error) in
            guard let data = data else {
                return
            }
            let str = String.init(data: data, encoding: String.Encoding.utf8)!
            let json = JSON.init(parseJSON: str)
            let songs = json["data"].map{ Song($0.1) }
            musicManager.list = songs
        }).resume()
    }

    @IBAction func touchEvent(_ sender: Any) {
        let vc = MusicViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

