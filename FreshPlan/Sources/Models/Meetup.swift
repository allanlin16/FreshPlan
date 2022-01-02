//
//  Meetup.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-16.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import RxDataSources

public struct Meetup: Decodable {
  public let id: Int
  public let meetupType: MeetupType
  public let user: User
  public let title: String
  public let description: String
  public let startDate: Date
  public let endDate: Date
  public let invitations: [Invitation]
  public let metadata: String
}

// MARK: Identity
extension Meetup: IdentifiableType {
  public typealias Identity = Int
  
  public var identity: Int {
    return id
  }
}

// MARK: Equatable
extension Meetup: Equatable {
  public static func ==(lhs: Meetup, rhs: Meetup) -> Bool {
    return lhs.id == rhs.id && lhs.title == rhs.title && lhs.description == rhs.description &&
           lhs.startDate == rhs.startDate && lhs.endDate == rhs.endDate && lhs.invitations.count == rhs.invitations.count &&
           lhs.metadata == rhs.metadata
  }
}
