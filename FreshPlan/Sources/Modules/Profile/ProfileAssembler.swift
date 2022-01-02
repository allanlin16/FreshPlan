//
//  ProfileAssembler.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-11-16.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit
import Moya

public final class ProfileAssembler {
	public static func make() -> UIViewController {
		let viewModel = ProfileViewModel(provider: provider)
		let router = ProfileRouter()
		
		return ProfileViewController(viewModel: viewModel, router: router)
	}
	
	private static var provider: MoyaProvider<FreshPlan> {
		return MoyaProvider<FreshPlan>(plugins: [NetworkLoggerPlugin(verbose: true)])
	}
}

