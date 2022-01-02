//
//  InviteAssembler.swift
//  FreshPlan
//
//  Created by Allan Lin on 2017-12-10.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit
import Moya

public final class InviteAssembler {
    public static func make() -> UIViewController {
        let viewModel = InviteViewModel(provider: provider)
        let router = InviteRouter()
        
        return InviteViewController(viewModel: viewModel, router: router)
    }
    
    private static var provider: MoyaProvider<FreshPlan> {
        return MoyaProvider<FreshPlan>(plugins: [NetworkLoggerPlugin(verbose: true)])
    }
}
