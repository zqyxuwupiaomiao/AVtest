//
//  VedioListViewController.swift
//  AVtest
//
//  Created by 周全营 on 2019/10/7.
//  Copyright © 2019 周全营. All rights reserved.
//

import UIKit
import AVKit

class VedioListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    lazy var tableView: UITableView = {
        var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCellID")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        return tableView
    }()
        
    var dataArray:Array<String>?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = "视频列表"
        self.view.addSubview(self.tableView)
        fetchData()
    }
    
    //MARK: 请求数据
    func fetchData() {
        dataArray = getVedioFileList()
        self.tableView.reloadData()
    }
    
    //MARK: UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let titleStr = self.dataArray![indexPath.row]
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCellID", for: indexPath)
        cell.textLabel?.text = titleStr
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action:UITableViewRowAction = UITableViewRowAction(style: .default, title: "删除") { (action, indexPath) in
            let titleStr = self.dataArray![indexPath.row]
            _ = deleteFile(urlStr: getVideoCachePath() + "/" + titleStr)
            self.fetchData()
        }
        return [action]
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let titleStr = self.dataArray![indexPath.row]
        addPlayer(urlStr: getVideoCachePath() + "/" + titleStr)
    }
    
    func addPlayer(urlStr:String) {
        //控制器推出的模式
        let player = AVPlayer(url: NSURL(fileURLWithPath: urlStr) as URL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated:true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
