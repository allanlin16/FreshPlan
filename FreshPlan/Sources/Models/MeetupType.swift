//
//  MeetupType.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-16.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation

public struct MeetupType: Decodable {
  public let id: Int
  public let type: String
}

extension MeetupType {
  public enum Options: String {
    case location
    case other
  }
}
