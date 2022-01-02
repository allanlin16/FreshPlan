//
//  VerifyAssembler.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-10-10.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import UIKit
import Moya

public final class VerifyAssembler {
	public static func make(email: String) -> UIViewController {
		let viewModel = VerifyViewModel(provider: provider, email: email)
		let router = VerifyRouter()
		
		return VerifyViewController(viewModel: viewModel, router: router)
	}
	
	public static var provider: MoyaProvider<FreshPlan> {
		return MoyaProvider<FreshPlan>(plugins: [NetworkLoggerPlugin(verbose: true)])
	}
}
