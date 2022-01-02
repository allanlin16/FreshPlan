//
//  MeetupRouter.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-10-13.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

public class MeetupRouter {
	public enum Routes: String {
		case meetup
    case addMeetupOption
    case addMeetup
	}
	
	fileprivate enum RouteError: Error {
		case invalidRoute(String)
	}
}

extension MeetupRouter: RouterProtocol {
	public func route(from context: UIViewController, to route: String, parameters: [String : Any]?) throws {
		
		guard let route = Routes(rawValue: route) else { throw RouteError.invalidRoute("Invalid route!") }
		
		switch route {
		case .meetup:
      guard let params = parameters, let meetupId = params["meetupId"] as? Int else { return }
			
      context.navigationController?.pushViewController(MeetupDetailAssembler.make(meetupId: meetupId), animated: true)
    case .addMeetupOption:
      guard let params = parameters, let viewModel = params["viewModel"] as? MeetupViewModel else { return }
      let dialog = MDCAlertController(title: "Add Meetup", message: "Please select which meetup option you would like to create.")
      let locationHandler = MDCAlertAction(title: "Location", handler: { [weak self] _ in
        guard let this = self else { return }
        try? this.route(
          from: context,
          to: MeetupRouter.Routes.addMeetup.rawValue,
          parameters: ["type": MeetupType.Options.location.rawValue, "viewModel": viewModel]
        )
      })
      let otherHandler = MDCAlertAction(title: "Other", handler: { [weak self] _ in
        guard let this = self else { return }
        try? this.route(
          from: context,
          to: MeetupRouter.Routes.addMeetup.rawValue,
          parameters: ["type": MeetupType.Options.other.rawValue, "viewModel": viewModel]
        )
      })
      let cancelHandler = MDCAlertAction(title: "Cancel", handler: nil)
      dialog.addAction(locationHandler)
      dialog.addAction(otherHandler)
      dialog.addAction(cancelHandler)
      
      context.present(dialog, animated: true, completion: nil)
      
      break
    case .addMeetup:
      guard let params = parameters,
        let type = params["type"] as? String,
        let viewModel = params["viewModel"] as? MeetupViewModel else { return }
      
      context.present(AddMeetupAssembler.make(meetupViewModel: viewModel, type: type), animated: true, completion: nil)
      
      break
		}
	}
}
