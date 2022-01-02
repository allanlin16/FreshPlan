//
//  MeetupDetailRouter.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-17.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import UIKit

public class MeetupDetailRouter {
  public enum Routes: String {
    case meetup
    case editMeetup
    case googlemaps
    case invitee
  }
  
  fileprivate enum RouteError: Error {
    case invalidRoute(String)
  }
}

extension MeetupDetailRouter: RouterProtocol {
  public func route(from context: UIViewController, to route: String, parameters: [String : Any]? = nil) throws {
    guard let route = Routes(rawValue: route) else {
      throw RouteError.invalidRoute("This is an invalid route!")
    }
    
    switch route {
    case .meetup:
      context.navigationController?.popViewController(animated: true)
    case .editMeetup:
      guard let params = parameters,
        let meetupId = params["meetupId"] as? Int,
        let viewModel = params["viewModel"] as? MeetupDetailViewModel else { return }
      
      context.present(EditMeetupAssembler.make(meetupId: meetupId, meetupDetailViewModel: viewModel), animated: true, completion: nil)
    case .googlemaps:
      guard let googleMapsURL = URL(string: "comgooglemaps://") else { return }
      guard let params = parameters, let latitude = params["latitude"] as? Double, let longitude = params["longitude"] as? Double else {
        return
      }
      // this only works if you have google maps installed
      if (UIApplication.shared.canOpenURL(googleMapsURL)) {
        let url = URL(string: "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving")
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
      } else {
        // redirect you to the site
        let url = URL(string: "https://maps.google.com/?q=@\(latitude),\(longitude)")
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
      }
    case .invitee:
      guard let params = parameters, let userId = params["inviteeId"] as? Int else { return }
      
      context.navigationController?.pushViewController(FriendAssembler.make(friendId: userId), animated: true)
    }
  }
}
