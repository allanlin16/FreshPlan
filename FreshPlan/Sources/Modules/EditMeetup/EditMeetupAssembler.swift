//
//  EditMeetupAssembler.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-24.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import Moya
import UIKit

public final class EditMeetupAssembler {
  public static func make(meetupId: Int, meetupDetailViewModel: MeetupDetailViewModel) -> UIViewController {
    let viewModel = EditMeetupViewModel(meetupId: meetupId, meetupDetailViewModel: meetupDetailViewModel, provider: provider)
    let router = EditMeetupRouter()
    
    return UINavigationController(rootViewController: EditMeetupViewController(viewModel: viewModel, router: router))
  }
  
  private static var provider: MoyaProvider<FreshPlan> {
    return MoyaProvider<FreshPlan>(plugins: [NetworkLoggerPlugin(verbose: true)])
  }
}
