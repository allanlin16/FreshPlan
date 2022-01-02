//
//  Token+.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-11-21.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import RxSwift
import JWTDecode
import MaterialComponents
import UIKit

// MARK:  Token Extension
/// tests if the jwt has been expired
//: TODO - Fix soon 
extension Token {
  
  // Observable check for each VC
	public static func getJWT() -> Observable<Int> {
		return Observable.just(decodeJWT)
			.map { token in
        if let token = token {
          if token.expired {
            return -1
          }
          return token.body["userId"] as! Int
        }
        return -1
      }
      .do(onNext: { token in
        if token == -1 {
          removeToken()
        }
      })
	}
  
  // Decodes the token
  public static var decodeJWT: JWT? {
    if let token = UserDefaults.standard.string(forKey: "token") {
      let jwt = try? decode(jwt: token)
      return jwt
    }
    return nil
  }
  
  // Removes the token
  private static func removeToken() {
    guard let window = UIApplication.shared.keyWindow else { fatalError() }
    UserDefaults.standard.removeObject(forKey: "token")
    let alertController = MDCAlertController(title: "Login Expired", message: "Your login credentials have expired. Please log back in.")
    let action = MDCAlertAction(title: "OK")
    alertController.addAction(action)
    window.rootViewController? = LoginAssembler.make()
    window.rootViewController?.present(alertController, animated: true)
  }
}
