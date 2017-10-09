//
//  MusicLrcView.swift
//  LrcTableView
//
//  Created by mac3 on 2017/9/22.
//  Copyright © 2017年 mac3. All rights reserved.
//

import UIKit
import Kingfisher

class LrcData {
    var beginTime: TimeInterval = 0
    var endTime: TimeInterval = 0
    var text: String = ""
    
    func getPregress(_ duration: TimeInterval) -> Float {
        let t = endTime - beginTime
        let d = duration - beginTime
        if beginTime <= duration && duration < endTime {
            return Float(d/t)
        }
        return 0
    }
}

class LrcInfo {
    //只对 00:00.00做处理
    static func getTime(_ time:String) -> TimeInterval {
        if time.count > 0 {
            let item = time.components(separatedBy: ":")
            let minute = TimeInterval(item.first!)
            let second = TimeInterval(item.last!)
            return minute! * 60 + second!
        }
        return 0
    }
    var list:[LrcData] = []
    init(path: String) {
        
        let handle = FileHandle(forReadingAtPath: path)
        let data = handle?.readDataToEndOfFile()
        handle?.closeFile()
        let string = String(data: data!, encoding: String.Encoding.utf8)
        setup(string)
    }
    init(string: String?) {
        setup(string)
    }
    func setup(_ string:String?) {
        let array = (string?.components(separatedBy: "\n"))!
        
        var lasttime: String = ""
        for item in array.reversed() {
            if item.contains("[ti:") || item.contains("[ar:") || item.contains("[al:") || item.contains("[by:") {
                continue
            }
            let newItem = item.replacingOccurrences(of: "[", with: "")
            let items = newItem.components(separatedBy: "]")
            let time = items.first!
            let song = items.last!
            let lrc = LrcData()
            lrc.beginTime = LrcInfo.getTime(time)
            lrc.endTime = LrcInfo.getTime(lasttime)
            lasttime = time
            lrc.text = song
            list.insert(lrc, at: 0)
        }
    }
    func getIndex(_ duration:TimeInterval) -> Int {
        var i = 0
        for item in list {
            if item.beginTime <= duration && duration < item.endTime {
                return i
            }
            i += 1
        }
        return list.count - 1
    }
}

class CoverView: UIView {
    var imageView1: UIImageView!
    var imageView2: UIImageView!
    var imageView3: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    func setup() {
        imageView1 = UIImageView(image: UIImage(named:"bg_cd_nearplay"))
        imageView2 = UIImageView(image: UIImage())
        imageView2.contentMode = .scaleAspectFill
        imageView2.frame = CGRect(x: 0, y: 0, width: 270, height: 270)
        imageView3 = UIImageView(image: UIImage(named:"center_cd_nearplay"))
        addSubview(imageView1)
        addSubview(imageView2)
        addSubview(imageView3)
    }
    override func layoutSubviews() {
        imageView1.center = CGPoint(x:bounds.width/2,y:bounds.width/2)
        imageView2.center = CGPoint(x:bounds.width/2,y:bounds.width/2)
        imageView3.center = CGPoint(x:bounds.width/2,y:bounds.width/2)
        imageView2.layer.cornerRadius = 270.0/2
        imageView2.layer.masksToBounds = true
    }
}

class LrcGradientView: UIView {
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        let context = UIGraphicsGetCurrentContext()
//        let colorsSpace = CGColorSpace.init(name: CGColorSpace.sRGB)
//        let colors: [CGFloat] = [
//            1.0,1.0,1.0,1.0,
//            0.0,0.0,0.0,0.0,
//            1.0,1.0,1.0,1.0,
//            ]
//        let locations: [CGFloat] = [0.0,0.5,1.0]
//        let gradient = CGGradient.init(colorSpace: colorsSpace!, colorComponents: colors, locations: locations, count: 3)
//        context?.drawLinearGradient(gradient!, start: rect.origin, end: CGPoint(x:rect.origin.x,y:rect.origin.y + rect.height), options: .drawsAfterEndLocation)
//    }
}

class MusicLrcView: UIView {

    var tableView: UITableView!
    var scrollView: UIScrollView!
    var selectButton: UIButton!
    var mvButton: UIButton!
    var coverView: CoverView!
    var lrclabel: UILabel!
    var lrcGradientView: LrcGradientView!
    
    var lrc: LrcInfo?
    var currentIndex = 0
    var playIndex = 0
    var isTouch = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    var song: Song? {
        didSet {
            reloaddata()
        }
    }
    
    func setup() {
        backgroundColor = .clear
        tableView = UITableView(frame: .zero, style: .plain)
//        let bundle = Bundle.init(path: Bundle.main.path(forResource: "Frameworks/DWMusic.framework/DWMusic", ofType: "bundle")!)
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: self.tableView.frame.height/2, left: 0, bottom: self.tableView.frame.height/2, right: 0)
        tableView.showsVerticalScrollIndicator = false
        
        scrollView = UIScrollView(frame: .zero)
        scrollView.addSubview(tableView)
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        addSubview(scrollView)
        
        lrcGradientView = LrcGradientView(frame:.zero)
        scrollView.addSubview(lrcGradientView)
        
        coverView = CoverView(frame: .zero)
        scrollView.addSubview(coverView)
        lrclabel = UILabel(frame: .zero)
        
        reloaddata()
    }
    
    func reloaddata() {
        if let song = song {
            coverView.imageView2.kf.setImage(with: URL.init(string: (song.cover)!))
            URLSession(configuration: URLSessionConfiguration.default).dataTask(with: URL.init(string: (song.lrc)!)!, completionHandler: { [weak self] (data, response, error) in
                let string = String.init(data: data!, encoding: String.Encoding.utf8)
                self?.lrc = LrcInfo(string:string!)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }).resume()
        }
    }
    
    func progress(_ duration:TimeInterval) {
        if let lrc = lrc {
            let index = lrc.getIndex(duration)
            let indexpath = IndexPath(row: index, section: 0)
            if playIndex != index {
                let lastIndexpath = IndexPath(row: playIndex, section: 0)
                let cell = tableView.cellForRow(at: lastIndexpath) as? TableViewCell
                cell?.progress = 0
                playIndex = index
                if !isTouch {
                    self.tableView.scrollToRow(at: indexpath, at: .middle, animated: true)
                }
            }
            
            let cell = tableView.cellForRow(at: indexpath) as? TableViewCell
            cell?.progress = duration
        }
    }
    
    override func layoutSubviews() {
        scrollView.frame = bounds
        coverView.frame = CGRect(x: (bounds.width - 340)/2, y: (bounds.height - 340)/2, width: 340, height: 340)
        scrollView.contentSize = CGSize(width:scrollView.frame.width * 2,height:scrollView.frame.height)
        tableView.frame = CGRect(x: frame.width, y: 0, width: frame.width, height: frame.height)
        lrcGradientView.frame = tableView.frame
    }
    
}

extension MusicLrcView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let lrc = lrc {
            return lrc.list.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        let data = lrc?.list[indexPath.row]
        cell.data = data
        return cell
    }
}
extension MusicLrcView: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            var progrpess = scrollView.contentOffset.x / scrollView.frame.width
            progrpess = min(progrpess, 1.0)
            progrpess = max(progrpess, 0.0)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            isTouch = true
        }
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == self.tableView {
            isTouch = false
        }
    }
}
