//
//  ResponseError.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-10-23.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation

/**
 * Class that conforms to JSON when an error appears
**/
public struct ResponseError: Decodable {
	public let reason: String
	public let error: Bool
}
