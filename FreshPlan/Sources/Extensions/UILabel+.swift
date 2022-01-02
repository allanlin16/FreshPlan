//
//  UILabel+.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-11-21.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

// MARK:  Reactive
extension Reactive where Base: UILabel {
	public var textColor: Binder<UIColor> {
		return Binder(self.base) { label, color in
			label.textColor = color
		}
	}
}
