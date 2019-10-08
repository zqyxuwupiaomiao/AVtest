//
//  ViewController.swift
//  AVtest
//
//  Created by 周全营 on 2019/10/6.
//  Copyright © 2019 周全营. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var manager:AVManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "首页"

        let barBtn1 = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(shutdown))
        
        let barBtn2 = UIBarButtonItem(title: "开始", style: .plain, target: self, action: #selector(beginNow))

        let barBtn3 = UIBarButtonItem(title: "查看列表", style: .plain, target: self, action: #selector(gotoList))

        self.navigationItem.leftBarButtonItem = barBtn2
        self.navigationItem.rightBarButtonItems = [barBtn1,barBtn3]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if manager == nil {
            manager = AVManager(view: self.view)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if manager != nil {
            manager?.shutdown()
        }
    }
    
   @objc func shutdown() {
        manager?.shutdown()
    }

    @objc func beginNow() {
        manager?.startUp()
     }
    
    @objc func gotoList() {
        let vc = VedioListViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

