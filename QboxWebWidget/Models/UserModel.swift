//
//  UserModel.swift
//  KenesWidget
//
//  Created by Nurken Tileubergenov on 31.10.2022.
//

import Foundation


public struct User {
  var id: Int? = nil
  var firstName: String? = nil
  var lastName: String? = nil
  var patronymic: String? = nil
  var birthDate: String? = nil
  var iin: String? = nil
  var phoneNumber: String? = nil
  var dynamicAttrs: [String: Any?] = [:]

  let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.YYYY"
    return dateFormatter
  }()
  
  var json: [String: Any?] {
    var json = dynamicAttrs
    json["user_id"] = id
    json["first_name"] = firstName
    json["last_name"] = lastName
    json["patronymic"] = patronymic
    json["iin"] = iin
    json["phone"] = phoneNumber
    json["birthdate"] = birthDate
    return json
  }
  
  public init(id: Int? = nil, firstName: String? = nil, lastName: String? = nil, patronymic: String? = nil, birthDate: Date? = nil, iin: String? = nil, phoneNumber: String? = nil, dynamicAttrs: [String: Any?] = [:]) {
    self.id = id
    self.firstName = firstName
    self.lastName = lastName
    self.patronymic = patronymic
    if let birthDate = birthDate {
      self.birthDate = dateFormatter.string(from: birthDate)
    }
    self.iin = iin
    self.phoneNumber = phoneNumber
    self.dynamicAttrs = dynamicAttrs
  }
}
