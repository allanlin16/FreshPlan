//
//  LocationAssembler.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-22.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit

public final class LocationAssembler {
  /**
    Creates an Meetup Model for the adding portion
   **/
  public static func make(meetupViewModel: AddMeetupViewModel) -> UIViewController {
    let viewModel = LocationViewModel(meetupViewModel: meetupViewModel)

    return UINavigationController(rootViewController: LocationViewController(viewModel: viewModel))
  }
  
  /**
    Creates a Edit Meetup Model
   **/
  public static func make(editMeetupViewModel: EditMeetupViewModel) -> UIViewController {
    let viewModel = LocationViewModel(editMeetupViewModel: editMeetupViewModel)
    
    return UINavigationController(rootViewController: LocationViewController(viewModel: viewModel))
  }
}
