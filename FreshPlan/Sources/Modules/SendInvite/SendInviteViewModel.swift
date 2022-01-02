//
//  SendInviteViewModel.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2018-01-07.
//  Copyright © 2018 St Clair College. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import RxDataSources
import UIKit

public protocol SendInviteViewModelProtocol {
  var invites: Variable<[SendInviteViewModel.Section]> { get }
  var meetup: Variable<Meetup?> { get }
  var friends: PublishSubject<[User]> { get }
  
  // set up the invites
  var inviteClicked: PublishSubject<IndexPath> { get }
  var addedInvites: Variable<[Int]> { get }
  var sendInvite: PublishSubject<Void> { get }
  var sendInviteSuccess: PublishSubject<Int> { get }
}

public class SendInviteViewModel: SendInviteViewModelProtocol {
  private let provider: MoyaProvider<FreshPlan>
  
  public var invites: Variable<[SendInviteViewModel.Section]> = Variable([])
  public var addedInvites: Variable<[Int]> = Variable([])
  public var sendInvite: PublishSubject<Void> = PublishSubject()
  public var sendInviteSuccess: PublishSubject<Int> = PublishSubject()
  public var inviteClicked: PublishSubject<IndexPath> = PublishSubject()
  
  public var meetup: Variable<Meetup?> = Variable(nil)
  public var friends: PublishSubject<[User]> = PublishSubject()
  
  public var sendTap: Observable<Void>!
  public var sendSuccess: PublishSubject<Void> = PublishSubject()
  
  private let disposeBag = DisposeBag()
  
  public init(provider: MoyaProvider<FreshPlan>) {
    self.provider = provider
    // set up the initial
    setup()
    // set up updated
    setupUpdatedMeetup()
    // send invite
    setupInvites()
  }
  
  private func setup() {
    let initMeetup = requestMeetup().map { SectionItem.meetup(id: -1, title: "", meetups: $0) }
    let sectionMeetup = initMeetup.map { Section.meetups(order: 0, title: "Meetup", items: [$0]) }
    // set up the initial friends
    let sectionFriends = Observable.just(Section.friends(order: 1, title: "Friends", items: []))
    // Setup the from
    Observable.from([sectionMeetup, sectionFriends])
      .flatMap { $0 }
      .toArray()
      .map { $0.sorted(by: { $0.order < $1.order }) }
      .bind(to: invites)
      .disposed(by: disposeBag)
  }
  
  private func setupUpdatedMeetup() {
    // if a meetup has been presented, we'll show the new one
    meetup
      .asObservable()
      .filterNil()
      .map { meetup -> Observable<([User], [User])> in
        if let jwt = Token.decodeJWT, let userId = jwt.body["userId"] as? Int {
          let users = meetup.invitations.map { $0.invitee }
          let requests = self.requestUsers(userId: userId)
          return requests.map { ($0.filter { $0 != meetup.user }, users) }
        }
        return Observable.empty()
      }
      .flatMap { $0 }
      .map { user -> [User] in
        return Array(Set(user.0).subtracting(user.1))
      }
      .map { users in
        return users.map { user in
          return SectionItem.friend(id: user.id, displayName: user.displayName, email: user.email, checked: false)
        }
      }
      .map { Section.friends(order: 1, title: "Friends", items: $0) }
      .subscribe(onNext: { [weak self] section in
        guard let this = self else { return }
        // we'll attempt to remove the last one, and add a new one
        this.invites.value.removeLast()
        this.invites.value.append(section)
      })
      .disposed(by: disposeBag)
    
  }
  
  private func setupInvites() {
    // check for an invite being sent
    
    sendInvite
      .asObservable()
      .flatMap { [unowned self] in return Observable.from(self.addedInvites.value) }
      .flatMap { [unowned self] invite -> Observable<Response> in
        return self.requestSendInvite(userId: invite, meetupId: self.meetup.value!.id)
      }
      .subscribe { [weak self] event in
        guard let this = self else { return }
        
        switch event {
        case .next(_):
          this.sendInviteSuccess.onNext(this.addedInvites.value.count)
        default: break
        }
      }
      .disposed(by: disposeBag)
    
    inviteClicked
      .asObservable()
      .subscribe(onNext: { [weak self] index in
        guard let this = self else { return }
        // fixed it up
        let invite = this.invites.value[index.section].items[index.row]
        if !invite.checked {
          this.addedInvites.value.append(invite.id)
        } else {
          if let index = this.addedInvites.value.index(of: invite.id) {
            this.addedInvites.value.remove(at: index)
          }
        }
        // set up the changes
        let newChecked = this.invites.value[index.section].check(at: index.row)
        this.invites.value[index.section] = newChecked
      })
      .disposed(by: disposeBag)
  }
  
  private func requestUsers(userId id: Int) -> Observable<[User]> {
    return provider.rx.request(.friends(id))
      .asObservable()
      .map([User].self, using: JSONDecoder.Decode)
      .catchErrorJustReturn([])
  }
  
  private func requestSendInvite(userId: Int, meetupId id: Int) -> Observable<Response> {
    return self.provider.rx.request(.sendInvite(userId, id))
      .filter(statusCodes: 200...299)
      .asObservable()
      .catchErrorJustComplete()
  }
  
  private func requestMeetup() -> Observable<[Meetup]> {
    return provider.rx.request(.meetup)
      .asObservable()
      .map([Meetup].self, using: JSONDecoder.Decode)
      .catchErrorJustReturn([])
  }
}

extension SendInviteViewModel {
  public enum Section {
    case meetups(order: Int, title: String, items: [SectionItem])
    case friends(order: Int, title: String, items: [SectionItem])
  }
  
  public enum SectionItem {
    case meetup(id: Int, title: String, meetups: [Meetup])
    case friend(id: Int, displayName: String, email: String, checked: Bool)
  }
}

extension SendInviteViewModel.Section {
  public var order: Int {
    switch self {
    case let .meetups(order, _, _):
      return order
    case let .friends(order, _, _):
      return order
    }
  }
  
  public var title: String {
    switch self {
    case let .meetups(_, title, _):
      return title
    case let .friends(_, title, _):
      return title
    }
  }
  
  public var items: [SendInviteViewModel.SectionItem] {
    switch self {
    case let .meetups(_, _, items):
      return items.map { $0 }
    case let .friends(_, _, items):
      return items.map { $0 }
    }
  }
  
  /**
   Unchecks or checks the mark based on what's given
   */
  public func check(at index: Int) -> SendInviteViewModel.Section {
    switch self {
    case let .friends(order, title, _):
      var newItems = items
      switch newItems[index] {
      case let .friend(id, displayName, email, checked):
        let newVal = (checked) ? false : true
        newItems[index] = .friend(id: id, displayName: displayName, email: email, checked: newVal)
      default: break
      }
      return SendInviteViewModel.Section.friends(order: order, title: title, items: newItems)
    default: return self
    }
  }
}

extension SendInviteViewModel.SectionItem {
  public var id: Int {
  switch self {
  case let .meetup(id, _, _):
    return id
  case let .friend(id, _, _, _):
    return id
    }
  }
  
  public var checked: Bool {
    switch self {
    case let .friend(_, _, _, checked):
      return checked
    default: return false
    }
  }
}

extension SendInviteViewModel.Section: AnimatableSectionModelType {
  public typealias Identity = Int
  
  public var identity: Int {
    return order
  }
  
  public typealias Item = SendInviteViewModel.SectionItem
  
  public init(original: SendInviteViewModel.Section, items: [Item]) {
    switch original {
    case let .friends(order: order, title: title,  _):
      self = .friends(order: order, title: title, items: items)
    case let .meetups(order, title, _):
      self = .meetups(order: order, title: title, items: items)
    }
  }
}

extension SendInviteViewModel.SectionItem: IdentifiableType {
  public typealias Identity = Int
  
  public var identity: Int {
    return id
  }
}

extension SendInviteViewModel.SectionItem: Equatable {
  public static func ==(lhs: SendInviteViewModel.SectionItem, rhs: SendInviteViewModel.SectionItem) -> Bool {
    return lhs.id == rhs.id && lhs.checked == rhs.checked
  }
}

extension SendInviteViewModel.Section: Equatable {
  public static func ==(lhs: SendInviteViewModel.Section, rhs: SendInviteViewModel.Section) -> Bool {
    return lhs.identity == rhs.identity
  }
}
