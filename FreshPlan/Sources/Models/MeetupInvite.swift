//
//  MeetUpInvite.swift
//  FreshPlan
//
//  Created by Allan Lin on 2018-01-04.
//  Copyright © 2018 St Clair College. All rights reserved.
//

import Foundation

public struct MeetupInvite: Decodable {
  public let id: Int
  public let inviter: User
  public let invitee: User
  public let accepted: Bool
  public let createdAt: Date
  public let updatedAt: Date
  public let meetupName: String
  public let meetupStartDate: Date
  public let meetupEndDate: Date
}
