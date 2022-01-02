//
//  SendInviteAssembler.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2018-01-07.
//  Copyright © 2018 St Clair College. All rights reserved.
//

import Foundation
import UIKit
import Moya

public final class SendInviteAssembler {
  public static func make() -> SendInviteViewController {
    let viewModel = SendInviteViewModel(provider: provider)
    
    return SendInviteViewController(viewModel: viewModel)
  }
  
  private static var provider: MoyaProvider<FreshPlan> {
    return MoyaProvider<FreshPlan>(plugins: [NetworkLoggerPlugin(verbose: true)])
  }
}
