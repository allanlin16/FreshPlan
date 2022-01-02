//
//  SettingsAssembler.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-28.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit
import Moya

public final class SettingsAssembler {
  public static func make() -> UIViewController {
    let viewModel = SettingsViewModel(provider: provider)
    
    return SettingsViewController(viewModel: viewModel)
  }
  
  private static var provider: MoyaProvider<FreshPlan> {
    return MoyaProvider<FreshPlan>(plugins: [NetworkLoggerPlugin(verbose: true)])
  }
}
