//
//  SettingsModel.swift
//  KenesWidget
//
//  Created by Nurken Tileubergenov on 31.10.2022.
//

import Foundation
import CoreTelephony
import UIKit

var printPrefix = "[QboxWW]"
var mErr = "📕 error: \(printPrefix)"
var mNot = "📘 note: \(printPrefix)"
//var mReq = "📓 data: \(printPrefix)"
//var mTst = "📔 test: \(printPrefix)"
//var mDec = "📙 \(printPrefix)"

public enum Language: String {
  case ru, kk, en
}

public class Settings {
  let url: String
  var language: Language
  var call: Call? = nil
  var user: User? = nil
  var device: Device? = nil
  var loggingEnabled: Bool? = nil
  var mobileRequired: Bool? = nil
  
  public init(url: String, language: Language, call: Call? = nil, user: User? = nil, device: Device? = nil, loggingEnabled: Bool? = nil) {
    self.url = url
    self.language = language
    self.call = call
    self.user = user
    self.device = device
    self.loggingEnabled = loggingEnabled
    if url.hasSuffix("/widget") || url.hasSuffix("/widget/") {
      self.mobileRequired = true
    } else {
      self.mobileRequired = nil
    }

    if self.device == nil {
      self.device = self.gatherDeviceData()
    }
  }
  
  func gatherDeviceData() -> Device {
    UIDevice.current.isBatteryMonitoringEnabled = true

    var device_data = Device(
      systemName: UIDevice.current.systemName,
      systemVersion: UIDevice.current.systemVersion,
      modelName: UIDevice.modelName,
      battery: DeviceBattery(
        batteryLevelPercentage: Int(UIDevice.current.batteryLevel*100),
        batteryIsCharging: UIDevice.current.batteryState == .charging
      )
    )
    if let infodict = Bundle.main.infoDictionary{
      device_data.appVersion = infodict["CFBundleShortVersionString"] as? String
    }
    return device_data
  }
  
  func prepareData() -> String? {
    let jsonData: [String: Any?] = [
      "user": user?.json,
      "call": call?.json,
      "device": device?.json
    ]
    if let data = try? JSONSerialization.data(withJSONObject: jsonData, options: .fragmentsAllowed),
       let string = String(data: data, encoding: .utf8){
      return string
    }
    return nil
  }
  
}
