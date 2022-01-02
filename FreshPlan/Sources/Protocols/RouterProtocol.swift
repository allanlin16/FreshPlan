//
//  RouterProtocol.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-10-05.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import UIKit

public protocol RouterProtocol {
	func route (
		from context: UIViewController,
		to route: String,
		parameters: [String: Any]?
	) throws
}
