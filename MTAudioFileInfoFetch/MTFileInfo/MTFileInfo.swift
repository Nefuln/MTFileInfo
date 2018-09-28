//
// MTFileInfo.swift
//
// 日期：2018/9/28.
// 作者：ManThirty

import UIKit

struct MTFilePosixPermissions: OptionSet {
    let rawValue: Int
    
    static let Read = MTFilePosixPermissions(rawValue: 1 << 1)
    static let Write = MTFilePosixPermissions(rawValue: 1 << 2)
    static let Execute = MTFilePosixPermissions(rawValue: 1 << 3)
    
    static let All: MTFilePosixPermissions = [.Read, .Write, .Execute]
}

class MTFileInfo: NSObject {
    
    init(filePath: String) {
        self.filePath = filePath
        super.init()
        self.setFileInfo()
    }
    
    /// 文件名称
    var fileName: String {
        return (self.filePath as NSString).lastPathComponent
    }
    
    /// 文件后缀名
    var fileSuffixName: String {
        return self.fileName.components(separatedBy: ".").last ?? ""
    }
    
    /// 创建日期
    var creatDate: Date?
    
    /// 最后修改日期
    var modificationDate: Date?
    
    /// 是否是隐藏文件
    var isHiddenFile: Bool = false
    
    /// 文件的硬链接数
    var referenceCount: Int = 0
    
    /// 目录的用户组ID
    var groupOwnerAccountID: UInt64 = 0
    
    /// 目录的用户组名字
    var groupOwnerAccountName: String?
    
    /// 目录所有者ID
    var ownerAccountID: UInt64 = 0
    
    /// 目录所有者名字
    var ownerAccountName: String?
    
    /// 文件管理权限
    var filePosixPermissions: MTFilePosixPermissions = .All
    
    /// 文件大小，单位：byte
    var fileSize: UInt64 = 0
    
    /// 文件路径
    var filePath: String
    
    /// 文件路径URL
    var fileURL: URL {
        return URL(fileURLWithPath: self.filePath)
    }
    
    /// 文件data
    var fileData: Data? {
        do {
            return try Data(contentsOf: self.fileURL)
        } catch let err as NSError {
            assertionFailure(err.localizedDescription)
            return nil
        }
    }
}

extension MTFileInfo {
    /// 获取其他文件信息
    func setFileInfo() {
        do {
            let attriDict: [FileAttributeKey : Any] = try FileManager.default.attributesOfItem(atPath: self.filePath)
            self.analysisFileAttriDict(dict: attriDict)
        } catch let err as NSError {
            assertionFailure("文件信息获取失败：\(err.localizedDescription)")
            return
        }
    }
    
    private func analysisFileAttriDict(dict: [FileAttributeKey : Any]) {
        dict.forEach { (attribute) in
            self.getConcreteInfo(for: attribute)
        }
    }
    
    private func getConcreteInfo(for attribute: (key: FileAttributeKey, value: Any)) {
        switch attribute.key {
        case FileAttributeKey.ownerAccountName:         // 目录所有者名字
            self.ownerAccountName = attribute.value as? String
        case FileAttributeKey.ownerAccountID:           // 目录所有者ID
            self.ownerAccountID = UInt64((attribute.value as! NSNumber).int64Value)
        case FileAttributeKey.posixPermissions:         // 目录访问权限
            self.getFilePosixPermissions(posixPermissions: Int16((attribute.value as! NSNumber).int16Value))
        case FileAttributeKey.groupOwnerAccountName:    // 目录的用户组名字
            self.groupOwnerAccountName = attribute.value as? String
        case FileAttributeKey.groupOwnerAccountID:      // 目录的用户组ID
            self.groupOwnerAccountID = UInt64((attribute.value as! NSNumber).int64Value)
        case FileAttributeKey.creationDate:             // 创建时间
            self.creatDate = attribute.value as? Date
        case FileAttributeKey.modificationDate:         // 最后修改时间
            self.modificationDate = attribute.value as? Date
        case FileAttributeKey.referenceCount:           // 文件的硬链接数
            self.referenceCount = Int((attribute.value as! NSNumber).intValue)
        case FileAttributeKey.extensionHidden:          // 是否是隐藏文件
            self.isHiddenFile = (attribute.value as! NSNumber).intValue == 0 ? false : true
        case FileAttributeKey.size:                     // 文件大小
            self.fileSize = UInt64((attribute.value as! NSNumber).int64Value)
        default:
            break
        }
    }
    
    private func getFilePosixPermissions(posixPermissions: Int16) {
        let posixPermissionsStr: String = "\(posixPermissions)"
        if !posixPermissionsStr.contains("4") {
            self.filePosixPermissions.remove(MTFilePosixPermissions.Read)
        }
        if !posixPermissionsStr.contains("2") {
            self.filePosixPermissions.remove(MTFilePosixPermissions.Write)
        }
        if !posixPermissionsStr.contains("1") {
            self.filePosixPermissions.remove(MTFilePosixPermissions.Execute)
        }
    }
    
}

extension MTFileInfo {
    override var description: String {
        return "fileName: \(self.fileName)\nfileSuffixName: \(self.fileSuffixName)\nfilePath: \(self.filePath)\ncreatDate: \(String(describing: self.creatDate))\nmodificationDate: \(String(describing: self.modificationDate))\nfileSize: \(self.fileSize)\nfilePosixPermissions: \(self.filePosixPermissions)\n"
    }
}
