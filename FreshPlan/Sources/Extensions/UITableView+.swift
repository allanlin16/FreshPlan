//
//  UITableView+.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-11-21.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit

// MARK:  UITableViewCell
//// this registers the cell, and returns the type back too. This will make it easier for us to check for guards
extension UITableView {
	public func registerCell<T: UITableViewCell>(_: T.Type) {
		register(T.self, forCellReuseIdentifier: String(describing: T.self))
	}
	
	public func dequeueCell<T>(ofType type: T.Type, for indexPath: IndexPath) -> T {
		return dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as! T
	}
}
