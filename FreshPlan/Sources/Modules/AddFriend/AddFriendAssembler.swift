//
//  AddFriendViewAssembler.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-03.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import Moya
import UIKit

public final class AddFriendAssembler {
  public static func make() -> UIViewController {
    let viewModel = AddFriendViewModel(provider: provider)
    let router = AddFriendRouter()
    let viewController = AddFriendViewController(viewModel: viewModel, router: router)
    
    return UINavigationController(rootViewController: viewController)
  }
  
  private static var provider: MoyaProvider<FreshPlan> {
    return MoyaProvider<FreshPlan>(plugins: [NetworkLoggerPlugin(verbose: true)])
  }
}
