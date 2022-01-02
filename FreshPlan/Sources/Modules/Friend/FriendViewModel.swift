//
//  FriendViewModel.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-08.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxDataSources

public protocol FriendViewModelProtocol {
  var name: Variable<String> { get }
  var tapSend: Observable<Void>! { get set }
  var disabledSend: Variable<Bool> { get }
  var sendFriend: Variable<Bool> { get }
  var friendDetail: Variable<[FriendViewModel.Section]> { get }
  
  func bindButtons()
}

public class FriendViewModel: FriendViewModelProtocol {
  private var provider: MoyaProvider<FreshPlan>!
  
  //MARK: Disposeable
  private let disposeBag: DisposeBag = DisposeBag()
  
  //MARK: Variables
  public var name: Variable<String> = Variable("")
  public var friendDetail: Variable<[FriendViewModel.Section]> = Variable([])
  public var disabledSend: Variable<Bool> = Variable(false)
  public var sendFriend: Variable<Bool> = Variable(false)
  
  //MARK: Observables
  public var tapSend: Observable<Void>!
  
  //MARK: Friend Id
  public var friendId: Int!
  
  public init(_ provider: MoyaProvider<FreshPlan>, friendId: Int) {
    self.provider = provider
    self.friendId = friendId
    
    let friend = self.requestUser(userId: friendId).share()
  
    friend
      .map { $0.displayName }
      .bind(to: name)
      .disposed(by: disposeBag)
    
    let profile = friend.map { SectionItem.profileTitle(order: 0, profileURL: $0.profileURL, fullName: $0.displayName) }
    let createdAt = friend
      .map { friend -> SectionItem in
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let date = df.string(from: friend.createdAt)
        return SectionItem.info(order: 2, type: "Joined:", title: date)
      }
    
    Observable.from([profile, createdAt])
      .flatMap { $0 }
      .toArray()
      .map { $0.sorted(by: { $0.order < $1.order }) }
      .map { Section(title: "", items: $0) }
      .toArray()
      .bind(to: friendDetail)
      .disposed(by: disposeBag)
    
    setupFriendRequest(friend)
  }
  
  private func setupFriendRequest(_ friend: Observable<User>) {
    let token = Token.getJWT().filter { $0 != -1 }.share()
    
    let friendRequestsList = token.flatMap { self.requestFriendRequests(userId: $0) }
    let friendsList = token.flatMap { self.requestFriends(userId: $0) }
    
    Observable.combineLatest(token.asObservable(), friend.asObservable(), friendRequestsList.asObservable(), friendsList.asObservable()) { token, friend, friendRequestsList, friendsList -> Bool in

      if token == friend.id {
        return false
      }
      
      if friendRequestsList.first(where: { $0.id == friend.id }) != nil {
        return false
      }
      
      if friendsList.first(where: { $0.id == friend.id }) != nil {
        return false
      }
      
      return true
    }
    .bind(to: disabledSend)
    .disposed(by: disposeBag)

  }
  
  public func bindButtons() {
    let token = Token.getJWT().filter { $0 != -1 }.share()
    
    tapSend
      .flatMap { _ -> Observable<Int> in return token }
      .flatMap { self.sendFriendRequest(userId: $0, friendId: self.friendId) }
      .filter { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .map { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .bind(to: self.sendFriend)
      .disposed(by: disposeBag)
  }
  
  private func requestUser(userId: Int) -> Observable<User> {
    return provider.rx.request(.user(userId))
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map(User.self, using: JSONDecoder.Decode)
  }
  
  private func requestFriends(userId: Int) -> Observable<[User]> {
    return provider.rx.request(.friends(userId))
      .asObservable()
      .map([User].self, using: JSONDecoder.Decode)
      .catchErrorJustReturn([])
  }
  
  private func requestFriendRequests(userId: Int) -> Observable<[Friend]> {
    return provider.rx.request(.friendRequests(userId))
      .asObservable()
      .map([Friend].self, using: JSONDecoder.Decode)
      .catchErrorJustReturn([])
  }
  
  private func sendFriendRequest(userId: Int, friendId: Int) -> Observable<Response> {
    return provider.rx.request(.sendFriendRequest(userId, friendId))
      .asObservable()
      
  }
}

extension FriendViewModel {
  public enum SectionItem {
    case profileTitle(order: Int, profileURL: String, fullName: String)
    case info(order: Int, type: String, title: String)
  }
  
  public struct Section {
    public var title: String
    public var items: [SectionItem]
  }
}

extension FriendViewModel.Section: SectionModelType {
  public typealias Item = FriendViewModel.SectionItem
  
  public init(original: FriendViewModel.Section, items: [Item]) {
    self = original
    self.items = items
  }
}

extension FriendViewModel.SectionItem: Equatable {
  public var order: Int {
    switch self {
    case let .info(order, _, _):
      return order
    case let .profileTitle(order, _, _):
      return order
    }
  }
  
  public static func ==(lhs: FriendViewModel.SectionItem, rhs: FriendViewModel.SectionItem) -> Bool {
    return lhs.order == rhs.order
  }
}
