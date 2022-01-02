//
//  AddFriendViewModel.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-03.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import RxSwift
import Moya
import RxDataSources

public protocol AddFriendViewModelProtocol {
  var searchText: Variable<String> { get }
  var friends: Variable<[User]> { get }
}

public class AddFriendViewModel: AddFriendViewModelProtocol {
  private var provider: MoyaProvider<FreshPlan>
  
  // MARK:  RxSwift Variables
  public var searchText: Variable<String> = Variable("")
  public var friends: Variable<[User]> = Variable([])
  
  // MARK:  DisposeBag
  private let disposeBag: DisposeBag = DisposeBag()
  
  public init(provider: MoyaProvider<FreshPlan>) {
    self.provider = provider
    
    searchText
      .asObservable()
      .throttle(0.4, scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .flatMapLatest { query -> Observable<[User]> in
        if query.isEmpty {
          return Observable.just([])
        }
        return self.requestFriends(query: query)
          .catchErrorJustReturn([])
      }
      .bind(to: friends)
      .disposed(by: disposeBag)
  }
  
  private func requestFriends(query: String) -> Observable<[User]> {
    return provider.rx.request(.friendSearch(query))
      .asObservable()
      .map([User].self, using: JSONDecoder.Decode)
  }
}
