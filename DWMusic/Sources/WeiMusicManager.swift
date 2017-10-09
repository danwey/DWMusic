//
//  WeiMusicManager.swift
//  WeiPlayer
//
//  Created by BmMac on 2017/8/28.
//  Copyright © 2017年 wei. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import RxSwift
import Kingfisher

open class WeiMusicManager: NSObject {
    //单例
    fileprivate static let sharedManager = WeiMusicManager.init()
    @objc class open func shared() -> WeiMusicManager {
        return WeiMusicManager.sharedManager
    }
    //只有out put
    var progressable = Variable<(TimeInterval,TimeInterval)?>(nil)
    var dlprogressable = Variable<(Float)>(0)
    var durationable = Variable<TimeInterval>(0)
    var songable = Variable<Song?>(nil)
    
    fileprivate var imageVariable = Variable<(String,String,UIImage)?>(nil)

    fileprivate var player:AVPlayer?
    fileprivate var playerItem:AVPlayerItem?
    fileprivate var duration:TimeInterval = 0
    fileprivate var curduration:TimeInterval = 0
    fileprivate var url:URL?
    fileprivate var currentIndex:Int = 0
    fileprivate var down: MusicDownLoad?
    fileprivate let disposeBag = DisposeBag()
    
    var list:[Song] = []
    public var test = NSMutableArray()
    var currentSong: Song? {
        return nil
    }
    fileprivate var cover: UIImage? {
        return nil
    }
    var playerPeriodicObserver:Any?

    fileprivate override init() {
        super.init()
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(true)
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print(error)
        }
        //获取歌曲封面
        songable.asObservable().subscribe(onNext: { (song) in
            guard let song = song, let cover = song.cover else {
                return
            }
            ImageDownloader.default.downloadImage(with: URL.init(string: cover)!, retrieveImageTask: nil, options: nil, progressBlock: nil) { [weak self] (image, error, url, data) in
                if let image = image {
                    self?.imageVariable.value = (song.name!,song.user!,image)
                }
            }
        }).disposed(by: disposeBag)
        //更新远程控制功能的
        let boservable1 = durationable.asObservable().filter { $0 != 0 }
        let boservable2 = imageVariable.asObservable().filter { $0 != nil }
        Observable.zip(boservable1, boservable2).subscribe(onNext: { [weak self] (data) in
            self?.updateLockScreenInfo(0.0,data.0,data.1?.0,data.1?.1,data.1?.2)
        }).disposed(by: disposeBag)
        
    }
    @objc open func start() {
        if (currentIndex >= list.count) {
            return
        }
        reset()
        stop()
        let song = list[currentIndex]
        self.songable.value = song
        down?.stop()
        down = MusicDownLoad(url: URL(string: song.url!)!,delegate: self)
        down?.start()
        if let down = down {
            var newurl = URLComponents(url: down.url, resolvingAgainstBaseURL: false)
            newurl?.scheme = "streaming"
            let asset = AVURLAsset(url: newurl!.url!)
            asset.resourceLoader.setDelegate(down, queue: DispatchQueue.main)
            playerItem = AVPlayerItem(asset: asset)
            
            playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            
            player = AVPlayer(playerItem: playerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(WeiMusicManager.itemDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            playerPeriodicObserver = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(3,30), queue: nil, using: { [weak self] (time) in
//                if (self?.player?.timeControlStatus == .playing) {
//                    self?.curduration = time.seconds
//                    self?.progressable.value = (curduration: (self?.curduration)!, duration: (self?.duration)!)
//                }
                self?.curduration = time.seconds
                self?.progressable.value = (curduration: (self?.curduration)!, duration: (self?.duration)!)
            })
        }
    }
    //停止
    @objc open func stop() {
        print("stop")
        if let playerItem = playerItem {
            playerItem.removeObserver(self, forKeyPath: "status")
        }
        if let player = player {
            if let playerPeriodicObserver = playerPeriodicObserver {
                player.removeTimeObserver(playerPeriodicObserver)
            }
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        stop()
    }
    
    //播放
    @objc open func play() {
        player?.play()
    }
    //重播
    @objc open func replay() {
        start()
        play()
    }
    //随机播放
    @objc open func random() {
        //随机排序
        //        var list = [1,2,3,4,5,6,7,8,9,10,11,12]
        //        var newlist:[Int] = []
        //
        //        for _ in list {
        //            let index = Int(arc4random()) % list.count
        //            let value = list.remove(at: index)
        //            newlist.append(value)
        //        }
        //        print(newlist)
    }
    //当前歌曲播放完
    @objc open func itemDidFinishPlaying(_ notification: Notification) {
        if self.curduration < self.duration {
            print("wait")
        }else {
            next()
        }
    }
    @objc open func reset() {
        progressable.value = nil
        dlprogressable.value = 0
    }
    //暂停
    @objc open func pause() {
        player?.pause()
    }
    //下一首
    @objc open func next() {
        if list.count > 0 {
            currentIndex = (currentIndex + 1)%list.count
            start()
            play()
        }
    }
    //上一首
    @objc open func previous() {
        if list.count > 0 {
            currentIndex = (currentIndex + list.count - 1)%list.count
            start()
            play()
        }
    }
    //调节声音大小
    @objc open func volume(value:Float) {
        player?.volume = value
    }
    //设置进度
    @objc open func seekTime(duration:TimeInterval, completionHandler: @escaping (Bool) -> Swift.Void) {
        let seekTime = CMTimeMake(Int64(duration*self.duration), 1)
        player?.seek(to: seekTime, completionHandler: completionHandler)
    }
    //更新锁屏
    open func updateLockScreenInfo(_ currentTime:TimeInterval?,_ duration:TimeInterval? ,_ name: String?,_ songer: String?,_ image: UIImage?) {
        var dict:[String : Any] = [:]
        if let name = name {
            dict[MPMediaItemPropertyTitle] = name
        }
        if true {
            dict[MPMediaItemPropertyAlbumTitle] = "wei喜爱的"
        }
        if let duration = duration {
            dict[MPMediaItemPropertyPlaybackDuration] = duration
        }
        if let currentTime = currentTime {
            dict[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        }
        if let songer = songer {
            dict[MPMediaItemPropertyArtist] = songer
        }
        if let image = image {
            dict[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: image)
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = dict
    }
    //键值监听
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let item =  object as? AVPlayerItem, let keyPath = keyPath {
            if item == self.playerItem {
                switch keyPath {
                case "status":
                    switch item.status {
                    case .readyToPlay:
                        print("readToPlay")
                        duration = item.duration.seconds
                        durationable.value = duration
                    case .failed:
                        print("failed")
                    case .unknown:
                        print("unknown")
                    }
                default:
                    break
                }
            }
        }
    }
}

extension WeiMusicManager: MusicDownloadDelegate {
    func downloadProgress(_ progress: Float) {
        dlprogressable.value = progress
    }
}

