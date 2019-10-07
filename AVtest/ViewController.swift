//
//  ViewController.swift
//  AVtest
//
//  Created by 周全营 on 2019/10/6.
//  Copyright © 2019 周全营. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var manager:AVManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barBtn1 = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(shutdown))
        
        let barBtn2 = UIBarButtonItem(title: "开始", style: .plain, target: self, action: #selector(beginNow))

        self.navigationItem.leftBarButtonItem = barBtn2
        self.navigationItem.rightBarButtonItem = barBtn1
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager = AVManager(view: self.view)
        manager.startUp()
    }
    
   @objc func shutdown() {
        manager.shutdown()
    }

    @objc func beginNow() {
        manager.startUp()
     }
}

