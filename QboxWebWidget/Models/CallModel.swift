//
//  CallModel.swift
//  KenesWidget
//
//  Created by Nurken Tileubergenov on 31.10.2022.
//

import Foundation


public struct Location {
  let latitude: Double
  let longitude: Double
  
  var json: [String: Any] {
    return [
      "latitude": latitude,
      "longitude": longitude
    ]
  }
  
  public init(latitude: Double, longitude: Double) {
    self.latitude = latitude
    self.longitude = longitude
  }
}

public enum CallType: String {
  case video, audio
}

public struct Call {
  let domain: String
  var type: CallType = .video
  let topic: String
  var location: Location? = nil
  var dynamicAttrs: [String: Any?] = [:]
  
  var json: [String: Any?] {
    var json = dynamicAttrs
    json["domain"] = domain
    json["type"] = type.rawValue
    json["topic"] = topic
    json["location"] = location?.json
    return json
  }
  
  public init(domain: String, type: CallType, topic: String, location: Location? = nil, dynamicAttrs: [String : Any?] = [:]) {
    self.domain = domain
    self.type = type
    self.topic = topic
    self.location = location
    self.dynamicAttrs = dynamicAttrs
  }
}
