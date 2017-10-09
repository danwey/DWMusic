//
//  MusicViewController.swift
//  WeiPlayer
//
//  Created by BmMac on 2017/8/25.
//  Copyright © 2017年 wei. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher
import SwiftyJSON

//这句到时放到全局位置
let musicManager = WeiMusicManager.shared()

open class MusicViewController: UIViewController {
    
    @IBOutlet weak var play_Button: UIButton!
    @IBOutlet weak var stop_Button: UIButton!
    @IBOutlet weak var list_Button: UIButton!
    @IBOutlet weak var close_Button: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var slider: MusicSlider!
    @IBOutlet weak var lrcView: MusicLrcView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var songnameLabel: UILabel!
    @IBOutlet weak var songerLabel: UILabel!
    
    var canSetSlider = true
    let disposeBag = DisposeBag()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        
        musicManager.progressable.asDriver().drive(onNext: { data in
            guard let curduration = data?.0,let duration = data?.1 else {
                return
            }
            if self.canSetSlider {
                if duration != 0 {
                    self.slider.value = Float(curduration/duration)
                }else {
                    self.slider.value = 0.0
                }
                self.label.text = curduration.toTimeString()
                self.timeLabel.text = duration.toTimeString()
                self.lrcView.progress(curduration)
            }
        }).disposed(by: disposeBag)
        
        musicManager.dlprogressable.asDriver().drive(onNext: { (progress) in
            self.slider.loadProgress = progress
        }).disposed(by: disposeBag)
        
        musicManager.songable.asDriver().drive(onNext: { (song) in
            if let song = song {
                self.songerLabel.text = song.user
                self.songnameLabel.text = song.name
                self.title = song.name
                self.lrcView.song = song
                self.imageView.kf.setImage(with: URL.init(string: song.cover!))
            }
        }).disposed(by: disposeBag)
        stop_Button.isHidden = true//之后改成 rxswift
        
        //test data
        
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
    
    @IBAction func musicPlay(_ sender: Any) {
        musicManager.play()
    }
    
    @IBAction func musicStop(_ sender: Any) {
        musicManager.pause()
    }
    
    @IBAction func musicNext(_ sender: Any) {
        musicManager.next()
    }
    
    @IBAction func musicPrevious(_ sender: Any) {
        musicManager.previous()
    }
    @IBAction func musicList(_ sender: Any) {
        let vc = MusicPlayListViewController()
        present(vc, animated: true, completion: nil)
    }
    @IBAction func musicClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func touchUp(_ sender: Any) {
        let slider = sender as! UISlider
        musicManager.pause()
        musicManager.seekTime(duration: TimeInterval(slider.value)) { [weak self] (isSucceed) in
            self?.canSetSlider = true
            musicManager.play()
        }
    }
    
    @IBAction func touchDown(_ sender: Any) {
                canSetSlider = false
    }
    
}


