//
//  MeetupAssembler.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-10-13.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit
import Moya

public final class MeetupAssembler {
	public static func make() -> MeetupViewController {
    let viewModel = MeetupViewModel(provider: provider)
		let router = MeetupRouter()
		
		return MeetupViewController(viewModel: viewModel, router: router)
	}
  
  private static var provider: MoyaProvider<FreshPlan> {
    return MoyaProvider<FreshPlan>(plugins: [NetworkLoggerPlugin(verbose: true)])
  }
}
