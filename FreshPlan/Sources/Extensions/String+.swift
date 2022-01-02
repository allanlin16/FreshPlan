//
//  String+.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-14.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation

extension String {
  // check for alphanumeric
  // i believe this regex is right
  var isAlphanumeric: Bool {
//    let alphaNumeric = "[^a-zA-Z0-9]"
//    let alphaNumericTest = NSPredicate(format:"SELF MATCHES %@", alphaNumeric)

    return range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
  }
  
  // simple check makes sure the count is greater than 8
  var isPassword: Bool {
    return count >= 8
  }
  
  // check for email
  // I THINK THIS REGEX IS RIGHT PLEASE SOMEONE CONFIRM??
  var isEmail: Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: self)
  }
}
