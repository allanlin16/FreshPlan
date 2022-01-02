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

public protocol AddMeetupViewModelProtocol {
  var meetup: Variable<[AddMeetupViewModel.Section]> { get }
  
  // we need form fields, to set up for our meeting as well
  var name: Variable<String> { get }
  var description: Variable<String> { get }
  var meetupType: Variable<String> { get }
  var startDate: Variable<Date?> { get }
  var endDate: Variable<Date?> { get }
  var metadata: Variable<String> { get }
  var address: Variable<String?> { get }
  var addButtonEnabled: Observable<Bool> { get }
  
  // button test
  var addButtonTap: Observable<Void>! { get set }
  var addButtonSuccess: PublishSubject<Bool> { get }
  var addButtonFail: PublishSubject<ResponseError> { get }
  var reloadMeetup: PublishSubject<Void> { get }
  
  func bindButtons()
}

public class AddMeetupViewModel: AddMeetupViewModelProtocol {
  // MARK: Private Instances
  private var type: String
  private var provider: MoyaProvider<FreshPlan>
  private var meetupViewModel: MeetupViewModel!
  
  public var meetup: Variable<[AddMeetupViewModel.Section]> = Variable([])
  
  // MARK: Form Fields
  public var name: Variable<String> = Variable("")
  public var description: Variable<String> = Variable("")
  public var meetupType: Variable<String> = Variable("")
  public var startDate: Variable<Date?> = Variable(nil)
  public var endDate: Variable<Date?> = Variable(nil)
  public var metadata: Variable<String> = Variable("")
  public var address: Variable<String?> = Variable(nil)
  
  public var addButtonEnabled: Observable<Bool> {
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
  
  public var addButtonTap: Observable<Void>!
  public var addButtonSuccess: PublishSubject<Bool> = PublishSubject()
  public var addButtonFail: PublishSubject<ResponseError> = PublishSubject()
  public var reloadMeetup: PublishSubject<Void> = PublishSubject()
  
  // MARK: Dispose
  private let disposeBag: DisposeBag = DisposeBag()
  
  public init(meetupViewModel: MeetupViewModel, type: String, provider: MoyaProvider<FreshPlan>) {
    self.meetupViewModel = meetupViewModel
    self.type = type
    self.provider = provider
    
    // reload
    reloadMeetup
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.meetupViewModel.refreshContent.on(.next(()))
      })
      .disposed(by: disposeBag)
    
    // set up table
    setup()
  }
  
  private func setup() {
    // conform the type right in
    let typeObservable = Observable.just(type).share()
    
    typeObservable
      .bind(to: meetupType)
      .disposed(by: disposeBag)
    
    // create the ones that we know are already there
    let name = Observable.just("Meetup Name").map { SectionItem.name(order: 0, label: $0) }
    let description = Observable.just("Enter in your description for your meetup name.").map { SectionItem.description(order: 1, label: $0) }
    
    let startDate = Observable.just("Start Date")
      .map { SectionItem.startDate(order: 1, label: $0) }
    
    let endDate = Observable.just("End Date")
      .map { SectionItem.endDate(order: 2, label: $0) }
    
    let metadata = typeObservable
      .map { type -> SectionItem in
        if type == MeetupType.Options.location.rawValue {
          return SectionItem.location(order: 3, label: "Location")
        } else {
          return SectionItem.other(order: 3, label: "Enter in additional information about your meetup!")
        }
    }
    
    // Conform it into the section
    Observable.from([name, description, metadata, startDate, endDate])
      .flatMap { $0 }
      .toArray()
      .map { $0.sorted(by: { $0.order < $1.order }) }
      .map { [Section(header: "", items: $0)] }
      .bind(to: meetup)
      .disposed(by: disposeBag)
  }
  
  public func bindButtons() {
    let btn = addButtonTap
      .flatMap { [weak self] _ -> Observable<Response> in
        guard let this = self else { fatalError() }
        return this.requestAddMeetup(title: this.name.value, desc: this.description.value, type: this.meetupType.value, metadata: this.metadata.value, startDate: this.startDate.value!.dateString, endDate: this.endDate.value!.dateString)
      }
      .share()
    
    btn
      .filter { $0.statusCode >= 299 }
      .map(ResponseError.self)
      .bind(to: addButtonFail)
      .disposed(by: disposeBag)
    
    btn
      .filter { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .map { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .bind(to: addButtonSuccess)
      .disposed(by: disposeBag)
  }
  
  private func requestAddMeetup(title: String, desc: String, type: String, metadata: String, startDate: String, endDate: String) -> Observable<Response> {
    return provider.rx.request(.addMeetup(title, desc, type, metadata, startDate, endDate))
      .asObservable()
  }
}

extension AddMeetupViewModel {
  public struct Section {
    public var header: String
    public var items: [SectionItem]
  }
  
  public enum SectionItem {
    case name(order: Int, label: String)
    case description(order: Int, label: String)
    case startDate(order: Int, label: String)
    case endDate(order: Int, label: String)
    case location(order: Int, label: String)
    case other(order: Int, label: String)
  }
}

//MARK: SectionModelType - RxDataSources
extension AddMeetupViewModel.Section: SectionModelType {
  public typealias Item = AddMeetupViewModel.SectionItem
  
  public init(original: AddMeetupViewModel.Section, items: [Item]) {
    self = original
    self.items = items
  }
}

//MARK: SectionItem
extension AddMeetupViewModel.SectionItem: Equatable {
  public var order: Int {
    switch self {
    case .name(let order, _):
      return order
    case .description(let order, _):
      return order
    case .startDate(let order, _):
      return order
    case .endDate(let order, _):
      return order
    case .location(let order, _):
      return order
    case .other(let order, _):
      return order
    }
  }
  
  public var label: String {
    switch self {
    case .name(_, let label):
      return label
    case .description(_, let label):
      return label
    case .startDate(_, let label):
      return label
    case .endDate(_, let label):
      return label
    case .location(_, let label):
      return label
    case .other(_, let label):
      return label
    }
  }
  
  public static func ==(lhs: AddMeetupViewModel.SectionItem, rhs: AddMeetupViewModel.SectionItem) -> Bool {
    return lhs.order == rhs.order
  }
}
