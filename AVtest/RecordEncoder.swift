//
//  RecordEncoder.swift
//  AVtest
//
//  Created by 周全营 on 2019/10/6.
//  Copyright © 2019 周全营. All rights reserved.
//

import UIKit
import AVFoundation

class RecordEncoder: NSObject {

    var writer:AVAssetWriter!//媒体写入对象
    var videoInput:AVAssetWriterInput!//视频写入
    var audioInput:AVAssetWriterInput!//音频写入
    var path:String?//媒体写入对象

    /**
    *  @param path 媒体存发路径
    *  @param height   视频分辨率的高
    *  @param width   视频分辨率的宽
    *  @param channels   音频通道
    *  @param samples 音频的采样比率
    */
    init(path:String, height:UInt32, width:UInt32, channels:UInt32, samples:Float64) {
        super.init()
        self.path = path
        
        do {
            try FileManager.default.removeItem(atPath: path)
            // 没有错误消息抛出
        } catch {
            // 有一个错误消息抛出
        }
        
        //初始化写入媒体类型为MP4类型
        do {
            self.writer = try AVAssetWriter(url: URL(fileURLWithPath: path), fileType: .mp4)
            // 没有错误消息抛出
        } catch {
            // 有一个错误消息抛出
        }
        //使其更适合在网络上播放
        self.writer.shouldOptimizeForNetworkUse = true
        //写入视频大小
        let numPixels = width * height;
        //每像素比特
        let bitsPerPixel:UInt32 = 6;//12
        let bitsPerSecond = numPixels * bitsPerPixel;
        let dic = [AVVideoAverageBitRateKey:NSNumber(value: bitsPerSecond),AVVideoExpectedSourceFrameRateKey:NSNumber(value: 10),AVVideoMaxKeyFrameIntervalKey:NSNumber(value: 10),AVVideoProfileLevelKey:AVVideoProfileLevelH264BaselineAutoLevel] as [String : Any]
        
        //初始化视频写入类
        self.videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: [AVVideoCodecKey:AVVideoCodecH264,AVVideoWidthKey:NSNumber(value: width * 2),AVVideoHeightKey:NSNumber(value: height * 2),AVVideoCompressionPropertiesKey:dic])
        //表明输入是否应该调整其处理为实时数据源的数据
        videoInput.expectsMediaDataInRealTime = true;
        //将视频输入源加入
        writer.add(videoInput)

        //初始化音频写入类
        if (samples != 0 && channels != 0) {
            audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: [AVFormatIDKey:NSNumber(integerLiteral: Int(kAudioFormatMPEG4AAC)),AVNumberOfChannelsKey:NSNumber(value: channels),AVSampleRateKey:NSNumber(value: samples),AVEncoderBitRateKey:NSNumber(value: 128000)])
            //表明输入是否应该调整其处理为实时数据源的数据
            audioInput.expectsMediaDataInRealTime = true;
            //将视频输入源加入
            writer.add(audioInput)
        }
    }
    
    /**
    *  通过这个方法写入数据
    *
    *  @param sampleBuffer 写入的数据
    *  @param isVideo      是否写入的是视频
    *
    *  @return 写入是否成功
    */
    func encodeFrame(sampleBuffer:CMSampleBuffer, isVideo:Bool) -> Bool {
        //数据是否准备写入
        if (CMSampleBufferDataIsReady(sampleBuffer)) {
            //写入状态为未知,保证视频先写入
            if (writer.status == .unknown && isVideo) {
                //获取开始写入的CMTime
                let startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                //开始写入
                writer.startWriting()
                writer.startSession(atSourceTime: startTime)
            }
            //写入失败
            if (writer.status == .failed) {
                print("writer error %@", writer.error?.localizedDescription ?? "")
                return false
            }
            //判断是否是视频
            if (isVideo) {
                //视频输入是否准备接受更多的媒体数据
                if (videoInput.isReadyForMoreMediaData) {
                    //拼接数据
                    videoInput.append(sampleBuffer)
                    return true
                }
            }else {
                //音频输入是否准备接受更多的媒体数据
                if (audioInput.isReadyForMoreMediaData) {
                    //拼接数据
                    audioInput.append(sampleBuffer)
                    return true
                }
            }
        }
        return true
    }
    
    func finishWithCompletionHandler(callBack: @escaping () -> Void) {
        self.writer.finishWriting(completionHandler: callBack)
    }
}
