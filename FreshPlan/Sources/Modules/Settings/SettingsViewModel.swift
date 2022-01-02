//
//  SettingsViewModel.swift
//  
//
//  Created by Johnny Nguyen on 2017-12-28.
//

import Foundation
import RxSwift
import RxDataSources
import UIKit
import Moya
import OneSignal
import MessageUI

public protocol SettingsViewModelProtocol {
  var settings: Variable<[SettingsViewModel.Section]> { get }
  var modelSelected: Observable<SettingsViewModel.SectionItem>! { get set }
  var switchSelected: Observable<Bool>! { get set }
  var canSendMail: PublishSubject<Void> { get }
  var sendEmail: PublishSubject<SettingsViewModel.Email> { get }
  var switchSuccess: PublishSubject<Void> { get }
  var switchRemove: PublishSubject<Void> { get }
  var switchRemoveSuccess: PublishSubject<Bool> { get }
  var switchSuccessAdd: PublishSubject<Bool> { get }
  
  func bindButtons()
  func bindCell()
}

public class SettingsViewModel: SettingsViewModelProtocol {
  private let provider: MoyaProvider<FreshPlan>
  
  public var settings: Variable<[SettingsViewModel.Section]> = Variable([])
  
  public var canSendMail: PublishSubject<Void> = PublishSubject()
  public var sendEmail: PublishSubject<SettingsViewModel.Email> = PublishSubject()
  public var switchSuccess: PublishSubject<Void> = PublishSubject()
  public var switchRemove: PublishSubject<Void> = PublishSubject()
  public var switchRemoveSuccess: PublishSubject<Bool> = PublishSubject()
  public var switchSuccessAdd: PublishSubject<Bool> = PublishSubject()
  
  public var modelSelected: Observable<SettingsViewModel.SectionItem>!
  public var switchSelected: Observable<Bool>!
  
  private let disposeBag = DisposeBag()
  
  public init(provider: MoyaProvider<FreshPlan>) {
    self.provider = provider
    setup()
  }
  
  private func setup() {
    // MARK: User
    let user = Token.getJWT()
      .flatMap { [unowned self] id in return self.requestUser(userId: id) }
      .materialize()
      .share()
    
    let userSettings = user
      .elements()
      .map { SectionItem.notifications(order: 0, title: "Push Notifications", enabled: $0.deviceToken != nil ? true : false) }
      .map { Section.user(order: 0, title: "User Settings", items: [$0]) }
    
    // MARK: Feedback
    let report = Observable.just("Report a bug").map { SectionItem.report(order: 0, title: $0) }
    let featureRequest = Observable.just("Suggestion & feature request").map { SectionItem.featureRequest(order: 1, title: $0) }
    
    let feedback = Observable.from([report, featureRequest])
      .flatMap { $0 }
      .toArray()
      .map { $0.sorted(by: { $0.order < $1.order }) }
      .map { Section.feedback(order: 1, title: "Feedback", items: $0) }
    
    // MARK: About
    let version = Observable.just(Bundle.main.releaseVersion)
      .filterNil()
      .map { SectionItem.version(order: 0, title: "Version", version: $0) }
    
    let build = Observable.just(Bundle.main.buildVersion)
      .filterNil()
      .map { SectionItem.build(order: 1, title: "Build Number", build: $0) }
    
    let licenses = Observable.just("Licenses We Use")
      .map { SectionItem.license(order: 2, title: $0) }
    
    let about = Observable.from([version, build, licenses])
      .flatMap { $0 }
      .toArray()
      .map { $0.sorted(by: { $0.order < $1.order }) }
      .map { Section.about(order: 2, title: "About", items: $0) }
    
    // MARK: Setup Table
    
    Observable.from([userSettings, about, feedback])
      .flatMap { $0 }
      .toArray()
      .map { $0.sorted(by: { $0.order < $1.order }) }
      .bind(to: settings)
      .disposed(by: disposeBag)
  }
  
  public func bindButtons() {
    modelSelected
      .subscribe(onNext: { [weak self] item in
        guard let this = self else { return }
        // check
        switch item {
        case .report:
          if !MFMailComposeViewController.canSendMail() {
            this.canSendMail.on(.next(()))
          } else {
            let email = Email(
              recipient: "johnny.nguyen39@stclairconnect.ca",
              cc: "allan.lin15@stclairconnect.ca",
              subject: "FreshPlan - Bug Report"
            )
            this.sendEmail.on(.next(email))
          }
        case .featureRequest:
          if !MFMailComposeViewController.canSendMail() {
            this.canSendMail.on(.next(()))
          } else {
            let email = Email(
              recipient: "johnny.nguyen39@stclairconnect.ca",
              cc: "allan.lin15@stclairconnect.ca",
              subject: "FreshPlan - Feature Request"
            )
            this.sendEmail.on(.next(email))
          }
        case .license:
          let url = URL(string: UIApplicationOpenSettingsURLString)
          if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
          }
        default:
          return
        }
      })
      .disposed(by: disposeBag)
  }
  
  public func bindCell() {
    switchSelected
      .subscribe(onNext: { [weak self] isOn in
        guard let this = self else { return }
        if isOn {
          OneSignal.promptForPushNotifications(userResponse: { accepted in
            if accepted {
              this.switchSuccess.on(.next(()))
            }
          })
        } else {
          // attempt to remove
          this.switchRemove.on(.next(()))
        }
      })
      .disposed(by: disposeBag)
    
    switchSuccess
      .asObservable()
      .flatMap { _ in return Token.getJWT() }
      .flatMap { [unowned self] id in return self.requestUpdateUser(userId: id, deviceToken: UserDefaults.standard.string(forKey: "deviceToken") ?? "") }
      .map { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .bind(to: switchSuccessAdd)
      .disposed(by: disposeBag)
    
    switchRemove
      .asObservable()
      .flatMap { _ in return Token.getJWT() }
      .flatMap { [unowned self] id in return self.requestUpdateUser(userId: id, deviceToken: "") }
      .map { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .bind(to: switchRemoveSuccess)
      .disposed(by: disposeBag)
  }
  
  private func requestUser(userId id: Int) -> Observable<User> {
    return provider.rx.request(.user(id))
      .asObservable()
      .map(User.self, using: JSONDecoder.Decode)
  }
  
  private func requestUpdateUser(userId id: Int, deviceToken: String) -> Observable<Response> {
    return provider.rx.request(.updateUserPushNotification(id, deviceToken))
      .asObservable()
  }
}

extension SettingsViewModel {
  public enum Section {
    case about(order: Int, title: String, items: [SectionItem])
    case feedback(order: Int, title: String, items: [SectionItem])
    case user(order: Int, title: String, items: [SectionItem])
  }
  
  public enum SectionItem {
    case version(order: Int, title: String, version: String)
    case build(order: Int, title: String, build: String)
    case report(order: Int, title: String)
    case featureRequest(order: Int, title: String)
    case license(order: Int, title: String)
    case notifications(order: Int, title: String, enabled: Bool)
  }
  
  public struct Email {
    public let recipient: String
    public let cc: String
    public let subject: String
  }
}

extension SettingsViewModel.Section: SectionModelType {
  public typealias Item = SettingsViewModel.SectionItem
  
  public var order: Int {
    switch self {
    case let .about(order, _, _):
      return order
    case let .feedback(order, _, _):
      return order
    case let .user(order, _, _):
      return order
    }
  }
  
  public var title: String {
    switch self {
    case let .about(_, title, _):
      return title
    case let .feedback(_, title, _):
      return title
    case let .user(_, title, _):
      return title
    }
  }
  
  public var items: [Item] {
    switch self {
    case let .about(_, _, items):
      return items.map { $0 }
    case let .feedback(_, _, items):
      return items.map { $0 }
    case let .user(_, _, items):
      return items.map { $0 }
    }
  }
  
  public init(original: SettingsViewModel.Section, items: [Item]) {
    switch original {
    case let .about(order, title, _):
      self = .about(order: order, title: title, items: items)
    case let .feedback(order, title, _):
      self = .feedback(order: order, title: title, items: items)
    case let .user(order, title, _):
      self = .user(order: order, title: title, items: items)
    }
  }
}

extension SettingsViewModel.Section: Equatable {
  public static func ==(lhs: SettingsViewModel.Section, rhs: SettingsViewModel.Section) -> Bool {
    return lhs.order == rhs.order
  }
}

extension SettingsViewModel.SectionItem: Equatable {
  
  public var order: Int {
    switch self {
    case let .build(order, _, _):
      return order
    case let .featureRequest(order, _):
      return order
    case let .report(order, _):
      return order
    case let .version(order, _, _):
      return order
    case let .license(order, _):
      return order
    case let .notifications(order, _, _):
      return order
    }
  }
  
  public var title: String {
    switch self {
    case let .build(_, title, _):
      return title
    case let .featureRequest(_, title):
      return title
    case let .report(_, title):
      return title
    case let .version(_, title, _):
      return title
    case let .license(_, title):
      return title
    case let .notifications(_, title, _):
      return title
    }
  }
  
  public static func ==(lhs: SettingsViewModel.SectionItem, rhs: SettingsViewModel.SectionItem) -> Bool {
    return lhs.order == rhs.order
  }
}
