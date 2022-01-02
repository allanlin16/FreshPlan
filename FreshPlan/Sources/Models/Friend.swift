//
//  Friend.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-11-16.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation

public struct Friend: Decodable {
  public let id: Int
  public let email: String
  public let verified: Bool
  public let displayName: String
  public let updatedAt: Date
  public let profileURL: String
  public let createdAt: Date
	public let accepted: Bool
}
