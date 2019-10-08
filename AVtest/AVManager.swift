//
//  AVManager.swift
//  AVtest
//
//  Created by 周全营 on 2019/10/6.
//  Copyright © 2019 周全营. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class AVManager: NSObject,AVCaptureAudioDataOutputSampleBufferDelegate,AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var captureSession: AVCaptureSession! //会话，协调着input到output的数据传输，input和output的桥梁
    var vInput: AVCaptureDeviceInput!//视频输入
    var aInput: AVCaptureDeviceInput!//音频输入
    var vOutput: AVCaptureVideoDataOutput!//视频输出
    var aOutput: AVCaptureAudioDataOutput!//音频输出
    var previewLayer: AVCaptureVideoPreviewLayer! /// 图像预览层，实时显示捕获的图像
    var vConnection: AVCaptureConnection! //视频录制连接
    var aConnection: AVCaptureConnection! //音频录制连接
    var recordEncoder: RecordEncoder? //音频录制连接
    
    var devicePosition = AVCaptureDevice.Position.back //摄像头位置，默认为前置摄像头
    var sessionPreset = AVCaptureSession.Preset.hd1920x1080 //分辨率
    var width:UInt32 = 720 //视频分辨的宽
    var height:UInt32 = 1280//视频分辨的高
    var videoOrientation = AVCaptureVideoOrientation.portrait // 摄像头方向 默认为当前手机屏幕方向
    
    var channels:UInt32 = 0//音频通道
    var samplerate = 0.0//音频采样率

    var timeOffset:CMTime!//录制的偏移CMTime
    var lastVideo:CMTime!//记录上一次视频数据文件的CMTime
    var lastAudio:CMTime!//记录上一次音频数据文件的CMTime
    var startTime:CMTime!//开始录制的时间
    var currentRecordTime:CGFloat = 0//当前录制时间
    let maxRecordTime:CGFloat = 60//最长录制时间

    var isCapturing = false //正在录制
    var isPaused = false //是否暂停
    
    var captureQueue = DispatchQueue(label: "com.capture.thread")
    
    var currentPath:String?
        
    init(view:UIView) {
        super.init()
        
        timeOffset = CMTimeMake(value: 0, timescale: 0)
        startTime = CMTimeMake(value: 0, timescale: 0)
        width = UInt32(view.bounds.size.width)
        height = UInt32(view.bounds.size.height)
        
        //视频的输入
        if let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera,.builtInMicrophone,.builtInTelephotoCamera], mediaType: .video, position: .back).devices.first {
            if let input = try? AVCaptureDeviceInput(device: device) {
                self.vInput = input
            } else {
                return
            }
        } else {
            return
        }
          
        //音频的输入
        if let input = try? AVCaptureDeviceInput(device: AVCaptureDevice.default(for: .audio)!) {
            self.aInput = input
        } else {
            return
        }
       
        //视频的输出
        self.vOutput = AVCaptureVideoDataOutput()
        // kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange 表示输出的视频格式为NV12
        self.vOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)]
        self.vOutput.setSampleBufferDelegate(self, queue: captureQueue)
        
        //音频的输出
        self.aOutput = AVCaptureAudioDataOutput()
        self.aOutput.setSampleBufferDelegate(self, queue: captureQueue)
        
        addCaptureSession()
        
        //视频链接
        self.vConnection = self.vOutput.connection(with: .video)
        self.vConnection.videoOrientation = self.videoOrientation
        
        //音频链接
        self.aConnection = self.aOutput.connection(with: .audio)
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer.frame = view.bounds
        view.layer.insertSublayer(self.previewLayer, at: 0)
        self.previewLayer.connection?.videoOrientation = videoOrientation
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        self.captureSession.startRunning()
    }
    //MARK: 添加session
    func addCaptureSession() {
        self.captureSession = AVCaptureSession()
        if self.captureSession.canAddInput(self.aInput) {
            self.captureSession.addInput(self.aInput)
        }
        
        if self.captureSession.canAddInput(self.vInput) {
            self.captureSession.addInput(self.vInput)
        }
        
        if self.captureSession.canAddOutput(self.vOutput) {
            self.captureSession.addOutput(self.vOutput)
        }
        
        if self.captureSession.canAddOutput(self.aOutput) {
            self.captureSession.addOutput(self.aOutput)
        }
        
        // ---  设置分辨率  ---
        if self.captureSession.canSetSessionPreset(self.sessionPreset) {
            self.captureSession.sessionPreset = self.sessionPreset
        }
    }
    
    //MARK: <-----------音视频数据输出的代理方法----------->
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        var isVideo = true
        if (!self.isCapturing  || self.isPaused) {
            return
        }
        if output != self.vOutput {
            isVideo = false
        }
        //初始化编码器，当有音频和视频参数时创建编码器
        if ((self.recordEncoder == nil) && !isVideo) {
            //设置音频格式
            if let fmt = CMSampleBufferGetFormatDescription(sampleBuffer) {
                if let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt) {
                    samplerate = asbd.pointee.mSampleRate
                    channels = asbd.pointee.mChannelsPerFrame
                }
            }
            self.currentPath = getVideoCachePath().appending("/" + getCurrenFileName())
            self.recordEncoder = RecordEncoder(path: self.currentPath!, height: height, width: width, channels: channels, samples: samplerate)
        }
        var sampleBuffer = sampleBuffer
        if timeOffset.value > 0 {
            sampleBuffer = adjustTime(sample: sampleBuffer, offset: timeOffset)
        }
        
        // 记录暂停上一次录制的时间
        var pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let dur = CMSampleBufferGetDuration(sampleBuffer)
        if (dur.value > 0) {
            pts = CMTimeAdd(pts, dur);
        }
        if (isVideo) {
            lastVideo = pts;
        }else {
            lastAudio = pts;
        }
        
        let dur1 = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        if (self.startTime.value == 0) {
            self.startTime = dur1;
        }
        
        let sub = CMTimeSubtract(dur, self.startTime)
        self.currentRecordTime = CGFloat(CMTimeGetSeconds(sub))
        if self.currentRecordTime > self.maxRecordTime {
            //最大录制时间
            return
        }
        _ = self.recordEncoder?.encodeFrame(sampleBuffer: sampleBuffer, isVideo: isVideo)
    }
          
    func adjustTime(sample:CMSampleBuffer, offset:CMTime) -> CMSampleBuffer {
        
        let count = UnsafeMutablePointer<CMItemCount>.allocate(capacity: 1)
        CMSampleBufferGetSampleTimingInfoArray(sample, entryCount: 0, arrayToFill: nil, entriesNeededOut: count)
        let pInfo = UnsafeMutablePointer<CMSampleTimingInfo>.allocate(capacity: count.pointee)
            //malloc(size(CMSampleTimingInfo) * count)
        
        CMSampleBufferGetSampleTimingInfoArray(sample, entryCount: count.pointee, arrayToFill: pInfo, entriesNeededOut: count)

        for i in 0 ... count.pointee {
            pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset)
            pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset)
        }
        
        let sout = UnsafeMutablePointer<CMSampleBuffer?>.allocate(capacity: 1024)
        CMSampleBufferCreateCopyWithNewTiming(allocator: nil, sampleBuffer: sample, sampleTimingEntryCount: count.pointee, sampleTimingArray: pInfo, sampleBufferOut: sout)
        return sout.pointee!
    }
    
    //MARK: 开始录制
    func startUp() {
        timeOffset = CMTimeMake(value: 0, timescale: 0)
        self.isCapturing = true
        self.isPaused = false
    }
    
    //MARK: 关闭录制并保存
    func shutdown() {
        if self.captureSession != nil {
            self.captureSession.stopRunning()
        }
        captureQueue.async {
            self.recordEncoder?.finishWithCompletionHandler {
                self.isCapturing = false
                self.recordEncoder = nil
                //保存到相册
                AuthorizedManager.checkPhotoAuthorize { result in
                    if result {
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: self.currentPath!))
                        }) { (result, erro) in
                            
                        }
                    }
                }
            }
        }
    }
    
    //MARK: 暂停录制
    func pauseCapture() {
        if self.isCapturing {
            self.isPaused = true
        }
    }
    
    //MARK: 继续录制
    func resumeCapture() {
        if (self.isPaused) {
            self.isPaused = false
        }
    }
    
    //MARK: 获取当前文件夹名字
    func getCurrenFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date()) + "video.mp4"
    }
}
