//
//  MusicDownload.swift
//  rxtableview
//
//  Created by mac3 on 2017/9/21.
//  Copyright © 2017年 wei. All rights reserved.
//

import Foundation
import AVFoundation
import MobileCoreServices

protocol MusicDownloadDelegate {
    func downloadProgress(_ progress: Float)
}

class MusicDownLoad : NSObject {
    //参数
    var url : URL
    var delegate: MusicDownloadDelegate?
    //内部变量
    fileprivate var length : Int64 = 0
    var session : URLSession?
    fileprivate var task : URLSessionDataTask?
    fileprivate var handle : FileHandle?
    fileprivate var data : Data?
    fileprivate var loadingReqs = NSMutableArray()
    fileprivate var readoffset = 0

    //方法
    init(url : URL,delegate : MusicDownloadDelegate) {
        self.url = url
        self.delegate = delegate
        super.init()
    }
    
    func start() {
        
        var request = URLRequest(url: url)
        
        handle = FileHandle(forUpdatingAtPath: getsavePath())
        data = handle?.readDataToEndOfFile()
        
        if data == nil {
            data = Data()
        }
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        length = Int64(data!.count)
        request.setValue("bytes=\(offset)-", forHTTPHeaderField: "Range")
        task = session?.dataTask(with: request)
        task?.resume()
    }
    func stop() {
        session?.invalidateAndCancel()
        handle?.closeFile()
        task?.cancel()
    }
    //内部方法
    fileprivate func getsavePath() -> String {
        let filename = url.lastPathComponent
        let dstPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let dir = (dstPath as NSString).appendingPathComponent("temp")
        let path = (dir as NSString).appendingPathComponent(filename)
        if !FileManager.default.fileExists(atPath: dir) {
            do {
                try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
            } catch _ {}
        }
        if !FileManager.default.fileExists(atPath: path) {
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        }else {
            try! FileManager.default.removeItem(atPath: path)
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        }
        print(path)
        return path
    }
    
    fileprivate var offset : Int64 {
        if let data = data {
            return Int64(data.count)
        }
        return 0
    }
}

extension MusicDownLoad : URLSessionDataDelegate {
    //开始下载
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        length = self.offset + response.expectedContentLength
        completionHandler(.allow)
    }
    //下载进度
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let offset = self.offset
        let progress = Float(dataTask.countOfBytesReceived + offset)/Float(dataTask.countOfBytesExpectedToReceive + offset)
        handle?.write(data)
        self.data?.append(data)
        delegate?.downloadProgress(progress)
        print("progress:\(progress)")
        proessLoadingRequest()
    }
    //下载完成
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil {
            if readoffset != length {
                proessLoadingRequest()
            }
            print("finish")
        }else {
            print(error!)
        }
        handle?.closeFile()
        handle = nil
    }
}

extension MusicDownLoad : AVAssetResourceLoaderDelegate {
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        loadingReqs.remove(loadingRequest)
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        loadingReqs.add(loadingRequest)
        proessLoadingRequest()
        return true
    }
    
    func proessLoadingRequest() {
        objc_sync_enter(self)
        var finishList:[AVAssetResourceLoadingRequest] = []
        for loadingReq in loadingReqs  {
            let loadingReq = loadingReq as! AVAssetResourceLoadingRequest
            if let data = data {
//                let contentType1 = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, "video/mp4" as CFString, nil)
//                let contentType = contentType1?.takeRetainedValue() as String?
                loadingReq.contentInformationRequest?.contentType = "public.mpeg-4"//contentType
                loadingReq.contentInformationRequest?.isByteRangeAccessSupported = true
                loadingReq.contentInformationRequest?.contentLength = length
                
                let cacheLength = data.count
                let fileLength = loadingReq.dataRequest!.requestedLength + Int(loadingReq.dataRequest!.requestedOffset)
                let currentoffset = Int(loadingReq.dataRequest!.currentOffset)
                let canReadLength = min(cacheLength,fileLength)
                
                if currentoffset < canReadLength {
                    let newData = data.subdata(in: currentoffset..<canReadLength)
                    loadingReq.dataRequest?.respond(with: newData)
                }
                
                if loadingReq.dataRequest!.currentOffset >= fileLength {
                    loadingReq.finishLoading()
                    finishList.append(loadingReq)
                }
            }
        }
        loadingReqs.removeObjects(in: finishList)
        objc_sync_exit(self)
    }
}
