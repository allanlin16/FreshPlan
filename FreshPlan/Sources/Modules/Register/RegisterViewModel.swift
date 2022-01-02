//
//  RegisterViewModel.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-10-10.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import RxSwift
import Moya

public protocol RegisterViewModelProtocol {
  var displayName: Variable<String> { get }
  var email: Variable<String> { get }
  var password: Variable<String> { get }
  var confirmPassword: Variable<String> { get }
  var signUpEnabled: Observable<Bool> { get }
  var error: Variable<String?> { get }
  
  // custom made error (help-text on material)
  // these must be publish subjects because we don't want to abuse variables
  var displayNameHelpText: PublishSubject<String?> { get }
  var emailHelpText: PublishSubject<String?> { get }
  var passwordHelpText: PublishSubject<String?> { get }
  var confirmPasswordHelpText: PublishSubject<String?> { get }
  
  var signUpTap: Observable<Void>! { get set }
  var signUpSuccess: Variable<Bool> { get }
  var signUpUnSuccessful: Variable<Bool> { get }
  func bindButtons()
  
}

public class RegisterViewModel: RegisterViewModelProtocol {
  
  private let provider: MoyaProvider<FreshPlan>
  
  private let disposeBag = DisposeBag()
  
  public var displayName: Variable<String> = Variable("")
  public var email: Variable<String> = Variable("")
  public var password: Variable<String> = Variable("")
  public var confirmPassword: Variable<String> = Variable("")
  public var error: Variable<String?> = Variable(nil)
  
  //MARK: - Help Texts
  public var displayNameHelpText: PublishSubject<String?> = PublishSubject()
  public var emailHelpText: PublishSubject<String?> = PublishSubject()
  public var passwordHelpText: PublishSubject<String?> = PublishSubject()
  public var confirmPasswordHelpText: PublishSubject<String?> = PublishSubject()
  
  // MARK: - Sign up info
  public var signUpEnabled: Observable<Bool> {
    return Observable.combineLatest(displayName.asObservable(), email.asObservable(), password.asObservable(), confirmPassword.asObservable()) { (displayName, email, password, confirmPassword) -> Bool in
      
      if self.displayName.value.isNotEmpty {
        if !displayName.isAlphanumeric {
          self.displayNameHelpText.on(.next("This display name must be alphanumeric!"))
        } else {
          self.displayNameHelpText.on(.next(nil))
        }
      }
      
      if self.email.value.isNotEmpty {
        if !email.isEmail {
          self.emailHelpText.on(.next("This email is invalid!"))
        } else {
          self.emailHelpText.on(.next(nil))
        }
      }
      
      if self.password.value.isNotEmpty {
        if !password.isPassword {
          self.passwordHelpText.on(.next("This password must be greater than a length of 8!"))
        } else {
          self.passwordHelpText.on(.next(nil))
        }
      }
      
      if self.confirmPassword.value.isNotEmpty {
        if confirmPassword != password {
          self.confirmPasswordHelpText.on(.next("Passwords do not match!"))
        } else {
          self.confirmPasswordHelpText.on(.next(nil))
        }
      }
    
      return displayName.isAlphanumeric && email.isEmail && password.isPassword && confirmPassword == password
    }
  }
  
  public var signUpTap: Observable<Void>!
  public var signUpSuccess: Variable<Bool> = Variable(false)
  public var signUpUnSuccessful: Variable<Bool> = Variable(false)
  
  public init(provider: MoyaProvider<FreshPlan>) {
    self.provider = provider
  }
  
  public func bindButtons() {
    let tap = signUpTap
      .flatMap { self.registerRequest(displayName: self.displayName.value, email: self.email.value, password: self.password.value) }
      .share()
    
    tap
      .filter { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .map { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .bind(to: self.signUpSuccess)
      .disposed(by: disposeBag)
    
    tap
      .filter { $0.statusCode > 299 }
      .map(ResponseError.self)
      .map { $0.reason }
      .bind(to: error)
      .disposed(by: disposeBag)
  }
  
  private func registerRequest(displayName: String, email: String, password: String) -> Observable<Response> {
    return self.provider.rx.request(.register(displayName, email, password, UserDefaults.standard.string(forKey: "deviceToken")))
      .asObservable()
  }
}
