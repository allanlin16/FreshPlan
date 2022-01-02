//
//  User.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-11-16.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation

public struct User: Decodable {
	public let id: Int
	public let email: String
	public let verified: Bool
	public let displayName: String
  public let deviceToken: String?
	public let updatedAt: Date
	public let profileURL: String
	public let createdAt: Date
}

extension User: Hashable, Equatable {
  public var hashValue: Int {
    return id
  }
  
  public static func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
  }
}
