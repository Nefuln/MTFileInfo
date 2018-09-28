
//
// MTAudioFileInfoFetch.swift
//
// 日期：2018/9/27.
// 作者：ManThirty

import UIKit
import AVFoundation

class MTMp3FileInfo: MTFileInfo {
    
    override init(filePath: String) {
        super.init(filePath: filePath)
        self.setBaseInfo()
    }
    
    /// 歌手
    var artist: String?
    
    /// 歌曲名称
    var songName: String?
    
    /// 专辑名称
    var albumName: String?
    
    /// 专辑图片
    var image: UIImage?
    
    /// 播放时长，单位：秒
    var duration: TimeInterval {
        return TimeInterval(asset.duration.value / Int64(asset.duration.timescale))
    }
        
    fileprivate var asset: AVURLAsset {
        return AVURLAsset(url: self.fileURL)
    }
    
}

extension MTMp3FileInfo {
    fileprivate func isMp3() -> Bool {
        guard let data = self.fileData else {
            return false
        }
        if data.count < 2 {
            return false
        }
        let typeIdentifying = data.subdata(in: 0..<2)
        return [UInt8](typeIdentifying) == [73, 68]
    }
    
    /// 获取音乐文件基本信息（专辑名称、歌手、歌曲名称）
    private func setBaseInfo() {
        if self.isMp3() == false {
            assertionFailure("该文件类型不是Mp3, 文件路径: \(self.filePath)")
            return
        }
        self.asset.availableMetadataFormats.forEach { (format) in
            self.getMetadata(for: format)
        }
    }
    
    private func getMetadata(for format: AVMetadataFormat) {
        self.asset.metadata(forFormat: format).forEach { (item) in
            guard let commonKey: AVMetadataKey = item.commonKey else {
                return
            }
            switch commonKey {
            case .commonKeyAlbumName:
                self.albumName = item.stringValue
            case .commonKeyArtist:
                self.artist = item.stringValue
            case .commonKeyTitle:
                self.songName = item.stringValue
            case .commonKeyArtwork:
                guard let dict: [String : Any] = item.value as? [String : Any] else { return }
                guard let imgData: Data = dict["data"] as? Data else { return }
                self.image = UIImage(data: imgData)
            default:
                break
            }
        }
    }    
}

extension MTMp3FileInfo {
    override var description: String {
        let superDesc = super.description
        return superDesc + "songName: \(self.songName ?? "")\nartist: \(self.artist ?? "")\nalbumName: \(self.albumName ?? "")\nimage: \(String(describing: self.image))\nduration: \(self.duration)"
    }
}
