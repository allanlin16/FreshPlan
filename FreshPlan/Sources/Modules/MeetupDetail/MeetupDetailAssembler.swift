//
//  MeetupDetailAssembler.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-17.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import Moya

public final class MeetupDetailAssembler {
  public static func make(meetupId: Int) -> UIViewController {
    let viewModel = MeetupDetailViewModel(provider: provider, meetupId: meetupId)
    let router = MeetupDetailRouter()
    
    return MeetupDetailViewController(viewModel: viewModel, router: router)
  }
  
  private static var provider: MoyaProvider<FreshPlan> {
    return MoyaProvider<FreshPlan>(plugins: [NetworkLoggerPlugin(verbose: true)])
  }
}
