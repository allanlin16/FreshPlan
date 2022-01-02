//
//  ProfileRouter.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-11-16.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
//
//  LoginRouter.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-10-05.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import UIKit

public class ProfileRouter {
	public enum Routes: String {
		case addFriend
    case friend
    case logout
	}
	
	fileprivate enum RouteError: Error {
		case invalidRoute(String)
	}
}

extension ProfileRouter: RouterProtocol {
	public func route(from context: UIViewController, to route: String, parameters: [String : Any]? = nil) throws {
		
		guard let route = Routes(rawValue: route) else {
			throw RouteError.invalidRoute("This is an invalid route!")
		}
  
		switch route {
		case .addFriend:
			context.present(AddFriendAssembler.make(), animated: true, completion: nil)
    case .logout:
      guard let window = UIApplication.shared.keyWindow else { return }
      UserDefaults.standard.removeObject(forKey: "token")
      window.rootViewController? = LoginAssembler.make()
    case .friend:
      guard let params = parameters, let friendId = params["friendId"] as? Int else { return }
      context.navigationController?.pushViewController(FriendAssembler.make(friendId: friendId), animated: true)
		}
	}
}

