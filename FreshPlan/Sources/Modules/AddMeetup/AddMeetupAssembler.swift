//
//  AddMeetupAssembler.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-22.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import Moya
import UIKit

public final class AddMeetupAssembler {
  public static func make(meetupViewModel: MeetupViewModel, type: String) -> UIViewController {
    let viewModel = AddMeetupViewModel(meetupViewModel: meetupViewModel, type: type, provider: provider)
    let router = AddMeetupRouter()
    let addViewController = AddMeetupViewController(viewModel: viewModel, router: router)
    return UINavigationController(rootViewController: addViewController)
  }
  
  private static var provider: MoyaProvider<FreshPlan> {
    return MoyaProvider<FreshPlan>(plugins: [NetworkLoggerPlugin(verbose: true)])
  }
}
