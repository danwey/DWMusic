//
//  MusicSlider.swift
//  testUIPresentationController
//
//  Created by mac3 on 2017/9/27.
//  Copyright © 2017年 mac3. All rights reserved.
//

import UIKit

class MusicSlider: UISlider {

    var loadProgress: Float = 0 {
        didSet {
            progressView.progress = loadProgress
        }
    }
    
    fileprivate var progressView: UIProgressView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let centerY = bounds.height/2
        progressView.frame = CGRect(x: 2, y: centerY - 1, width: bounds.width - 4, height: 2)
    }
    
    fileprivate func setup() {
        minimumTrackTintColor = UIColor(red: 90/255.0, green: 26/255.0, blue: 168/255.0, alpha: 1.0)
        maximumTrackTintColor = .clear
        setThumbImage(UIImage(), for: .normal)
        progressView = UIProgressView(frame: .zero)
        progressView.progressTintColor = UIColor(white: 0.8, alpha: 1.0)
        progressView.trackTintColor = UIColor(white: 0.9, alpha: 1.0)
        addSubview(progressView)
        loadProgress = 0.5
    }
}
