//
//  EditMeetupRouter.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-24.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import UIKit

public class EditMeetupRouter {
  public enum Routes: String {
    case location
  }
  
  fileprivate enum RouteError: Error {
    case invalidRoute(String)
  }
}

extension EditMeetupRouter: RouterProtocol {
  public func route(from context: UIViewController, to route: String, parameters: [String : Any]? = nil) throws {
    
    guard let route = Routes(rawValue: route) else {
      throw RouteError.invalidRoute("This is an invalid route!")
    }
    
    switch route {
    case .location:
      guard let params = parameters, let viewModel = params["viewModel"] as? EditMeetupViewModel else { return }
      context.present(LocationAssembler.make(editMeetupViewModel: viewModel), animated: true, completion: nil)
    }
  }
}
