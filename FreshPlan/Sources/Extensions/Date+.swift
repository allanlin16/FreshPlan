//
//  Date+.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-23.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation

extension Date {
  public var dateString: String {
    let dateFormat = DateFormatter()
    dateFormat.calendar = Calendar(identifier: .iso8601)
    dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    return dateFormat.string(from: self)
  }
}
