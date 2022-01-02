//
//  Bundle+.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-30.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit

extension Bundle {
  public var releaseVersion: String? {
    return infoDictionary?["CFBundleShortVersionString"] as? String
  }
  
  public var buildVersion: String? {
    return infoDictionary?["CFBundleVersion"] as? String
  }
}
