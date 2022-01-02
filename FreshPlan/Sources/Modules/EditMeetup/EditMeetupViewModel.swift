//
//  AddMeetupViewModel.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-22.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import RxSwift
import RxOptional
import RxDataSources
import Moya
import CoreLocation

public protocol EditMeetupViewModelProtocol {
  var meetupList: Variable<[EditMeetupViewModel.Section]> { get }
  
  // we need form fields, to set up for our meeting as well
  var name: Variable<String> { get }
  var description: Variable<String> { get }
  var meetupType: Variable<String> { get }
  var startDate: Variable<Date?> { get }
  var endDate: Variable<Date?> { get }
  var metadata: Variable<String> { get }
  var address: Variable<String?> { get }
  var submitButtonEnabled: Observable<Bool> { get }
  
  // button test
  var submitButtonTap: Observable<Void>! { get set }
  var submitButtonSuccess: PublishSubject<Bool> { get }
  var submitButtonFail: PublishSubject<ResponseError> { get }
  var reloadMeetup: PublishSubject<Void> { get }
  
  func bindButtons()
}

public class EditMeetupViewModel: EditMeetupViewModelProtocol {
  // MARK: Private Instances
  private let meetupId: Int!
  private let provider: MoyaProvider<FreshPlan>
  private let meetupDetailViewModel: MeetupDetailViewModel!
  
  public var meetupList: Variable<[EditMeetupViewModel.Section]> = Variable([])
  
  // MARK: Form Fields
  public var name: Variable<String> = Variable("")
  public var description: Variable<String> = Variable("")
  public var meetupType: Variable<String> = Variable("")
  public var startDate: Variable<Date?> = Variable(nil)
  public var endDate: Variable<Date?> = Variable(nil)
  public var metadata: Variable<String> = Variable("")
  public var address: Variable<String?> = Variable(nil)
  
  public var submitButtonEnabled: Observable<Bool> {
    return Observable.combineLatest(name.asObservable(), description.asObservable(), meetupType.asObservable(), startDate.asObservable(), endDate.asObservable(), metadata.asObservable()) { name, desc, type, startDate, endDate, metadata in
      
      guard name.isNotEmpty else { return false }
      guard desc.isNotEmpty else { return false }
      guard startDate != nil, endDate != nil else { return false }
      
      if type == MeetupType.Options.location.rawValue && metadata.isNotEmpty {
        return true
      } else if type == MeetupType.Options.other.rawValue {
        return true
      } else {
        return false
      }
    }
  }
  
  public var submitButtonTap: Observable<Void>!
  public var submitButtonSuccess: PublishSubject<Bool> = PublishSubject()
  public var submitButtonFail: PublishSubject<ResponseError> = PublishSubject()
  public var reloadMeetup: PublishSubject<Void> = PublishSubject()
  
  // MARK: Dispose
  private let disposeBag: DisposeBag = DisposeBag()
  
  public init(meetupId: Int, meetupDetailViewModel: MeetupDetailViewModel, provider: MoyaProvider<FreshPlan>) {
    self.meetupId = meetupId
    self.meetupDetailViewModel = meetupDetailViewModel
    self.provider = provider
    
    // reload
    reloadMeetup
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.meetupDetailViewModel.refreshContent.on(.next(()))
      })
      .disposed(by: disposeBag)
    
    // set up table
    setup(meetupId)
  }
  
  private func setup(_ meetupId: Int) {
    
    let meetup = Observable.just(meetupId)
      .flatMap { [unowned self] id in return self.requestMeetup(meetupId: id) }
      .materialize()
      .share()
    
    meetup
      .elements()
      .map { $0.meetupType.type }
      .bind(to: meetupType)
      .disposed(by: disposeBag)
    
    meetup
      .elements()
      .map { $0.metadata }
      .bind(to: self.metadata)
      .disposed(by: disposeBag)
    
    // create the ones that we know are already there
    let name = meetup.elements().map { SectionItem.name(order: 0, label: "Meetup Name", placeholder: $0.title) }
    let description = meetup.elements().map { SectionItem.description(order: 1, label: "Enter in your description for your meetup name.", placeholder: $0.description) }
    let startDate = meetup.elements().map { SectionItem.startDate(order: 2, label: "Start Date", placeholder: $0.startDate) }
    let endDate = meetup.elements().map { SectionItem.endDate(order: 3, label: "End Date", placeholder: $0.endDate) }
    let metadata = meetup.elements().map { meetup -> SectionItem? in
      if meetup.meetupType.type == MeetupType.Options.location.rawValue {
        return SectionItem.location(order: 4, label: "Location")
      } else {
        if meetup.metadata.isNotEmpty {
          if let data = meetup.metadata.data(using: .utf8) {
            let other = try JSONDecoder().decode(Other.self, from: data)
            return SectionItem.other(order: 4, label: "Enter in additional Information", notes: other.notes)
          }
        } else {
          return SectionItem.other(order: 4, label: "Enter in additional Information", notes: "")
        }
      }
      return nil
    }.filterNil()
    
    // Conform it into the section
    Observable.from([name, description, metadata, startDate, endDate])
      .flatMap { $0 }
      .toArray()
      .map { $0.sorted(by: { $0.order < $1.order }) }
      .map { [Section(header: "", items: $0)] }
      .catchErrorJustReturn([])
      .bind(to: meetupList)
      .disposed(by: disposeBag)
  }
  
  public func bindButtons() {
    let btn = submitButtonTap
      .flatMap { [weak self] _ -> Observable<Response> in
        guard let this = self else { fatalError() }
        return this.requestEditMeetup(meetupId: this.meetupId, title: this.name.value, desc: this.description.value, type: this.meetupType.value, metadata: this.metadata.value, startDate: this.startDate.value!.dateString, endDate: this.endDate.value!.dateString)
      }
      .share()
    
    btn
      .filter { $0.statusCode >= 299 }
      .map(ResponseError.self)
      .bind(to: submitButtonFail)
      .disposed(by: disposeBag)
    
    btn
      .filter { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .map { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .bind(to: submitButtonSuccess)
      .disposed(by: disposeBag)
  }
  
  private func requestEditMeetup(meetupId: Int, title: String, desc: String, type: String, metadata: String, startDate: String, endDate: String) -> Observable<Response> {
    return provider.rx.request(.editMeetup(meetupId, title, desc, type, metadata, startDate, endDate))
      .asObservable()
  }
  
  private func requestMeetup(meetupId: Int) -> Observable<Meetup> {
    return provider.rx.request(.getMeetup(meetupId))
      .asObservable()
      .map(Meetup.self, using: JSONDecoder.Decode)
  }
}

extension EditMeetupViewModel {
  public struct Section {
    public var header: String
    public var items: [SectionItem]
  }
  
  public enum SectionItem {
    case name(order: Int, label: String, placeholder: String)
    case description(order: Int, label: String, placeholder: String)
    case startDate(order: Int, label: String, placeholder: Date)
    case endDate(order: Int, label: String, placeholder: Date)
    case location(order: Int, label: String)
    case other(order: Int, label: String, notes: String)
  }
}

//MARK: SectionModelType - RxDataSources
extension EditMeetupViewModel.Section: SectionModelType {
  public typealias Item = EditMeetupViewModel.SectionItem
  
  public init(original: EditMeetupViewModel.Section, items: [Item]) {
    self = original
    self.items = items
  }
}

//MARK: SectionItem
extension EditMeetupViewModel.SectionItem: Equatable {
  public var order: Int {
    switch self {
    case .name(let order, _, _):
      return order
    case .description(let order, _, _):
      return order
    case .startDate(let order, _, _):
      return order
    case .endDate(let order, _, _):
      return order
    case .location(let order, _):
      return order
    case .other(let order, _, _):
      return order
    }
  }
  
  public var label: String {
    switch self {
    case .name(_, let label, _):
      return label
    case .description(_, let label, _):
      return label
    case .startDate(_, let label, _):
      return label
    case .endDate(_, let label, _):
      return label
    case .location(_, let label):
      return label
    case .other(_, let label, _):
      return label
    }
  }
  
  public static func ==(lhs: EditMeetupViewModel.SectionItem, rhs: EditMeetupViewModel.SectionItem) -> Bool {
    return lhs.order == rhs.order
  }
}

