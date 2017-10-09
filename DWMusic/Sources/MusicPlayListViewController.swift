//
//  MusicPlayListViewController.swift
//  rxtableview
//
//  Created by mac3 on 2017/9/26.
//  Copyright © 2017年 wei. All rights reserved.
//

import UIKit

class PresentationController: UIPresentationController {
    
    var bview: UIView!
    
    override func presentationTransitionWillBegin() {
        if let containerView = containerView {
            bview = UIView.init(frame: containerView.bounds)
            bview.backgroundColor = .black
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(PresentationController.touchEvent(tap:)))
            bview.addGestureRecognizer(tap)
            bview.alpha = 0.0
            containerView.addSubview(bview)
            UIView.animate(withDuration: 0.3, animations: {
                self.bview.alpha = 0.3
            })
        }
    }
    
    override func dismissalTransitionWillBegin() {
        UIView.animate(withDuration: 0.3) {
            self.bview.alpha = 0.0
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let rect = containerView!.bounds
        return CGRect(x: 0, y: rect.height/3, width: rect.width, height: rect.height*2/3)
    }
    
    @objc func touchEvent(tap:UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
}

class MusicPlayListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewWillLayoutSubviews() {
        tableView.frame = view.bounds
    }
    @IBAction func closeEvent(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension MusicPlayListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicManager.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        let song = musicManager.list[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = song.name
        return cell
    }

}

extension MusicPlayListViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController.init(presentedViewController: presented, presenting: presenting)
    }
}
