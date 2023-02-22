//
//  CallModel.swift
//  KenesWidget
//
//  Created by Nurken Tileubergenov on 31.10.2022.
//

import Foundation

public struct DeviceBattery {
  var batteryLevelPercentage: Int? = nil
  var batteryIsCharging: Bool? = nil
  
  var json: [String: Any?] {
    return [
      "percentage": batteryLevelPercentage,
      "is_charging": batteryIsCharging
    ]
  }
  
  public init(batteryLevelPercentage: Int? = nil, batteryIsCharging: Bool? = nil) {
    self.batteryLevelPercentage = batteryLevelPercentage
    self.batteryIsCharging = batteryIsCharging
  }
}

public struct Device {
  var systemName: String? = nil
  var systemVersion: String? = nil
  var modelName: String? = nil
  var mobileOperator: String? = nil
  var appVersion: String? = nil
  var battery: DeviceBattery? = nil
  
  var json: [String: Any?] {
    return [
      "os": systemName,
      "os_ver": systemVersion,
      "name": modelName,
      "mobile_operator": mobileOperator,
      "app_ver": appVersion,
      "battery": battery?.json
    ]
  }
  
  public init(systemName: String? = nil, systemVersion: String? = nil, modelName: String? = nil, mobileOperator: String? = nil, appVersion: String? = nil, battery: DeviceBattery? = nil) {
    self.systemName = systemName
    self.systemVersion = systemVersion
    self.modelName = modelName
    self.mobileOperator = mobileOperator
    self.appVersion = appVersion
    self.battery = battery
  }
}
