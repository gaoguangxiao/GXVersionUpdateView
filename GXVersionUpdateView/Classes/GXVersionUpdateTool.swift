//
//  GXVersionUpdateTool.swift
//  KidReading
//
//  Created by zoe on 2019/8/12.
//  Copyright © 2019 putao. All rights reserved.
//

import Foundation
import GGXSwiftExtension

enum PTVersionCompare {
    case None
    case Equal
    case Descending
    case Ascending //升级
}

enum PTVersionUpdateStatus {
    case None
    case Optional
    case Force
}

let kVersionUpdateLayerTag = 1777
let kVersionIntervalTime: Int =  60 * 60;
let kCancelUpdateTime = "cancelUpdateTime"


public class GXVersionUpdateTool: NSObject {
    
    public static let share = GXVersionUpdateTool()
    
    public var updateButtonEvent :((Bool)-> Void )? = nil
    
    public var themeColor: UIColor
    
    public override init() {
        themeColor = UIColor.init(hex: "FFD661")
    }
    
    public func handleVersionUpdate (infoMin: String?,infoLatest: String?, infoTitle:String?, infoReleaseNote: String?, infoDownloadUrl: String?, vc: UIViewController,updateEvent: @escaping (Bool)->Void) {
        
        self.updateButtonEvent = updateEvent

        guard let minVersion = infoMin ,
              let latestVersion =  infoLatest,
              let release_note =  infoReleaseNote,
              let download_url =  infoDownloadUrl
        else {
            self.updateButtonEvent?(false)
            return
        }
        
        guard download_url.count > 0 , let url = download_url.toUrl  else { return }
        
        let currentVersion = kAppVersion ?? ""
       
        var result = compareVersion(v1: currentVersion, v2: latestVersion)
        
        
        if result != PTVersionCompare.Ascending  {
            self.updateButtonEvent?(false)
            return
        }
        result = compareVersion(v1: currentVersion, v2: minVersion)
        
        var needUpdate = PTVersionUpdateStatus.None

        if result == PTVersionCompare.Ascending  {
            needUpdate = PTVersionUpdateStatus.Force
        } else {
//            let cancelUpdateTimeStr: String = UserDefaults.standard.object(forKey: kCancelUpdateTime) as? String ?? ""
//            let cancelUpdateTime = cancelUpdateTimeStr.toInt64() ?? 0
//            if cancelUpdateTime == 0 || (Date.currentTimestamp.toInt64() ?? 0) - cancelUpdateTime > kVersionIntervalTime{
                needUpdate = PTVersionUpdateStatus.Optional
//            }
        }
        if needUpdate == PTVersionUpdateStatus.None {
            self.updateButtonEvent?(false)
            return
        }
        
        if let window = UIApplication.rootWindow {
            if let preUpdateVw =  window.viewWithTag(kVersionUpdateLayerTag) {
                window.bringSubviewToFront(preUpdateVw)
                return
            }
        }
        
        
        let title =  infoTitle ?? "APP更新啦！"
        
        let alertView = GXVersionUpdateView.init(frame: CGRect.zero)
        alertView.tag = kVersionUpdateLayerTag
        alertView.themeColor = themeColor
        alertView.showVersionUpdateView(vc: vc,
                                        title: title,
                                        info: release_note, 
                                        forceUpdate: needUpdate == .Force) { isForceUpdate in
            UserDefaults.versionUpdate = ""
            if isForceUpdate {
//                UIApplication.shared.openURL(url)
                UIApplication.shared.open(url)
            } else {
                let cancelUpdateTime = Date.currentTimestamp
                UserDefaults.standard.set(cancelUpdateTime, forKey: kCancelUpdateTime)
                UserDefaults.standard.synchronize()
                //记录本次更新时间
                self.updateButtonEvent?(false)
            }
        }
    }
    
    private func compareVersion(v1 : String , v2 : String) -> PTVersionCompare {
        
        if v1.isEmpty || v2.isEmpty {
            return PTVersionCompare.None
        }
        
        let components1 = v1.components(separatedBy: ".")
        let components2 = v2.components(separatedBy: ".")

        let length = components1.count > components2.count ? components2.count : components1.count
        
        for index in 0 ..< length {
            let stringNumber1 = components1[index] as NSString
            let stringNumber2 = components2[index] as NSString
            if stringNumber1.intValue > stringNumber2.intValue {
                return  PTVersionCompare.Descending
            } else if stringNumber1.intValue < stringNumber2.intValue {
                return  PTVersionCompare.Ascending
            } else {
                continue
            }
        }

        let gap = components1.count - components2.count
        if gap != 0 {
            let components = gap > 0 ? components1 : components2
            let start = gap > 0 ? components2.count : components1.count
            for index in start ..< components.count {
                let stringNumber = components[index] as NSString
                if stringNumber.intValue > 0 {
                    return gap > 0 ? PTVersionCompare.Descending : PTVersionCompare.Ascending
                }
            }
        }
        return PTVersionCompare.Equal
    }
}
