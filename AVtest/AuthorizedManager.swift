//
//  AuthorizedManager.swift
//  AVtest
//
//  Created by 周全营 on 2019/10/8.
//  Copyright © 2019 周全营. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class AuthorizedManager: NSObject {

    /**
    * 相机权限
    */
    class func checkCameraAuthorize(callBack:@escaping (Bool)->(Void)) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        // .notDetermined  .authorized  .restricted  .denied
        if authStatus == .notDetermined {
            // 第一次触发授权 alert
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                callBack(granted)
            })
        } else if authStatus == .authorized {
            callBack(true)
        } else {
            callBack(false)
        }
    }

    /**
    * 相册权限
    */
    class func checkPhotoAuthorize(callBack:@escaping (Bool)->(Void)) {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        
        // .notDetermined  .authorized  .restricted  .denied
        if authStatus == .notDetermined {
            // 第一次触发授权 alert
            PHPhotoLibrary.requestAuthorization { (status:PHAuthorizationStatus) -> Void in
                if(status == .authorized){
                    callBack(true)
                }else{
                    callBack(false)
                }
            }
        } else if authStatus == .authorized  {
            callBack(true)
        } else {
            callBack(false)
        }
    }

    /**
    * 麦克风权限
    */
    class func checkRecodAuthorize(callBack:@escaping (Bool)->(Void)){
        AVAudioSession.sharedInstance().requestRecordPermission { result in
            if result {
                callBack(true)
            }else{
                callBack(false)
            }
        }
    }

}
