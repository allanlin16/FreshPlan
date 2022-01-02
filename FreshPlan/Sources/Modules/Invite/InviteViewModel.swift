//
//  InviteViewModel.swift
//  FreshPlan
//
//  Created by Allan Lin on 2017-12-10.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Moya
import RxSwift
import RxDataSources

public protocol InviteViewModelProtocol {
  var invitations: Variable<[InviteViewModel.Section]> { get }
  var acceptInvitation: PublishSubject<IndexPath> { get }
  var acceptInvitaionSuccess: PublishSubject<String?> { get }
  var declineInvitation: PublishSubject<IndexPath> { get }
  var declineInvitationSuccess: PublishSubject<String?> { get }
  var refreshContent: PublishSubject<Void> { get }
  var refreshSuccess: PublishSubject<Void> { get }
  
  //func bindButtons()
}

public class InviteViewModel: InviteViewModelProtocol {
  private let provider: MoyaProvider<FreshPlan>!
  
  public var acceptInvitaionSuccess: PublishSubject<String?> = PublishSubject()
  public var declineInvitationSuccess: PublishSubject<String?> = PublishSubject()
  public var acceptInvitation: PublishSubject<IndexPath> = PublishSubject()
  public var declineInvitation: PublishSubject<IndexPath> = PublishSubject()
  public var refreshContent: PublishSubject<Void> = PublishSubject()
  public var refreshSuccess: PublishSubject<Void> = PublishSubject()
  
  public var invitations: Variable<[InviteViewModel.Section]> = Variable([])
  
  // MARK: disposeBag
  private let disposeBag: DisposeBag = DisposeBag()
  
  public init(provider: MoyaProvider<FreshPlan>) {
    self.provider = provider
    
    refreshContent
      .asObservable()
      .flatMap { self.requestInvitation() }
      .map { $0.filter { !$0.accepted } }
      .map { [Section(header: "", items: $0)] }
      .do(onNext: { [weak self] meetup in
        self?.refreshSuccess.on(.next(()))
      })
      .catchErrorJustReturn([])
      .bind(to: invitations)
      .disposed(by: disposeBag)
    
    requestInvitation()
      .map { $0.filter { !$0.accepted } }
      .map { Section(header: "", items: $0) }
      .toArray()
      .bind(to: invitations)
      .disposed(by: disposeBag)
      
    declineInvitation.asObservable()
      .map { [unowned self] index in return self.invitations.value[index.section].items[index.row] }
      .map { [unowned self] invite -> Observable<(MeetupInvite, Response)> in
        let request = self.deleteInvitation(inviteId: invite.id)
        return request.map{ (invite, $0) }
        }
      .flatMap { $0 }
      .filter { $0.1.statusCode >= 200 && $0.1.statusCode <= 299 }
      .map { $0.0 }
      .map { [unowned self] invite -> String? in
        if let index = self.invitations.value[0].items.index(of: invite) {
          self.invitations.value[0].items.remove(at: index)
          return invite.meetupName
        }
        return nil
      }
      .bind(to: declineInvitationSuccess)
      .disposed(by: disposeBag)
    
    acceptInvitation.asObservable()
      .map { [unowned self] index in return self.invitations.value[index.section].items[index.row] }
      .map { [unowned self] invite -> Observable<(MeetupInvite, Response)> in
        let request = self.acceptInvitation(inviteId: invite.id)
        return request.map{ (invite, $0) }
      }
      .flatMap { $0 }
      .filter { $0.1.statusCode >= 200 && $0.1.statusCode <= 299 }
      .map { $0.0 }
      .map { [unowned self] invite -> String? in
        if let index = self.invitations.value[0].items.index(of: invite) {
          self.invitations.value[0].items.remove(at: index)
          return invite.meetupName
        }
        return nil
      }
      .bind(to: acceptInvitaionSuccess)
      .disposed(by: disposeBag)
  }
  
  private func requestInvitation() -> Observable<[MeetupInvite]> {
    return provider.rx.request(.invitations)
      .asObservable()
      .map([MeetupInvite].self, using: JSONDecoder.Decode)
      .catchErrorJustReturn([])
    
  }
  
  private func acceptInvitation(inviteId: Int) -> Observable<Response> {
    return provider.rx.request(.acceptInvite(inviteId))
      .asObservable()
  }
  
  private func deleteInvitation(inviteId id: Int) -> Observable<Response> {
    return provider.rx.request(.deleteInvitation(id))
      .asObservable()
  }
  
  private func getMeetup(meetUpId id: Int) -> Observable<Meetup> {
    return provider.rx.request(.getMeetup(id))
      .asObservable()
      .map(Meetup.self, using: JSONDecoder.Decode)
  }
}

extension InviteViewModel {
  public struct Section {
    public var header: String
    public var items:[MeetupInvite]
  }
}

// MARK: Identity
extension MeetupInvite: IdentifiableType {
  public typealias Identity = Int
  
  public var identity: Int {
    return id
  }
}

// MARK: Equatable
extension MeetupInvite: Equatable {
  public static func ==(lhs: MeetupInvite, rhs: MeetupInvite) -> Bool {
    return lhs.id == rhs.id
  }
}

extension InviteViewModel.Section: AnimatableSectionModelType {
  public typealias Item = MeetupInvite
  
  public var identity: String {
    return header
  }
  
  public init(original: InviteViewModel.Section, items: [Item]) {
    self = original
    self.items = items
  }
}
