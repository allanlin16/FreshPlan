//
//  Invite.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-16.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation

public struct Invitation: Decodable {
  public let id: Int
  public let inviter: User
  public let invitee: User
  public let accepted: Bool
  public let createdAt: Date
  public let updatedAt: Date
}
