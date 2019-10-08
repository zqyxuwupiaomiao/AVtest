//
//  File.swift
//  AVtest
//
//  Created by 周全营 on 2019/10/7.
//  Copyright © 2019 周全营. All rights reserved.
//

import Foundation

/**
 * 录音文件存放的文件夹
 */
func getVideoCachePath() -> String {
    let videoCache = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/videos")
    let fileManager = FileManager.default;
    let existed = fileManager.fileExists(atPath: videoCache ?? "")
    if (!existed) {
        try? fileManager.createDirectory(atPath: videoCache ?? "", withIntermediateDirectories: true, attributes: nil)
    }
    return videoCache ?? "";
}

func getVedioFileList() -> Array<String> {
    let fileManager = FileManager.default
    do {
      return try fileManager.contentsOfDirectory(atPath: getVideoCachePath())
    } catch {
        return []
    }
}

func deleteFile(urlStr:String) -> Bool {
    let fileManager = FileManager.default
    do {
        try fileManager.removeItem(atPath: urlStr)
    } catch {
        return false
    }
    return true
}


//func testAlert(title:String){
//    DispatchQueue.main.async {
//        let alertController = UIAlertController(title: "提示", message: title, preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil);
//            alertController.addAction(cancelAction)
//        self.superVC.present(alertController, animated: true, completion: nil)
//    }
//}
