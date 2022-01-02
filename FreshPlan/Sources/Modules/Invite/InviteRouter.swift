//
//  InviteRouter.swift
//  FreshPlan
//
//  Created by Allan Lin on 2017-12-10.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit

public class InviteRouter {
  public enum Routes: String {
    case sendInvite
  }
  
  fileprivate enum RouteError: Error {
    case invalidRoute(String)
  }
}

extension InviteRouter: RouterProtocol {
  public func route(from context: UIViewController, to route: String, parameters: [String : Any]?) throws {
    
    guard let route = Routes(rawValue: route) else { throw RouteError.invalidRoute("Invalid route!") }
    
    switch route {
    case .sendInvite:
      context.present(SendInviteAssembler.make(), animated: true, completion: nil)
      break
    }
  }
}
