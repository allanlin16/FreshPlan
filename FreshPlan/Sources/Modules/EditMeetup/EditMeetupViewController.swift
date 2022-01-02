//
//  AddMeetupViewController.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-22.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import MaterialComponents
import RxSwift
import RxDataSources
import CoreLocation

public final class EditMeetupViewController: UIViewController {
  // MARK: Required
  private var viewModel: EditMeetupViewModelProtocol!
  private var router: EditMeetupRouter!
  
  // MARK: Location
  public let locationManager: CLLocationManager = CLLocationManager()
  
  // MARK: AppBar
  private let appBar: MDCAppBar = MDCAppBar()
  private var closeButton: UIBarButtonItem!
  private var addButton: UIBarButtonItem!
  
  // MARK: TableView
  private var tableView: UITableView!
  fileprivate var dataSource: RxTableViewSectionedReloadDataSource<EditMeetupViewModel.Section>!
  
  private let disposeBag: DisposeBag = DisposeBag()
  
  public convenience init(viewModel: EditMeetupViewModel, router: EditMeetupRouter) {
    self.init(nibName: nil, bundle: nil)
    self.viewModel = viewModel
    self.router = router
    
    addChildViewController(appBar.headerViewController)
  }
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nil, bundle: nil)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override var childViewControllerForStatusBarStyle: UIViewController? {
    return appBar.headerViewController
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setNeedsStatusBarAppearanceUpdate()
    
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    locationManager.requestWhenInUseAuthorization()
    prepareView()
  }
  
  private func prepareView() {
    prepareTableView()
    prepareNavigationBar()
    prepareNavigationCloseButton()
    prepareNavigationAddButton()
    appBar.addSubviewsToParent()
  }
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.separatorInset = .zero
    tableView.layoutMargins = .zero
    tableView.estimatedRowHeight = 70
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.tableFooterView = UIView(frame: .zero)
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
    
    tableView.registerCell(EditMeetupTextFieldCell.self)
    tableView.registerCell(EditMeetupTextViewCell.self)
    tableView.registerCell(EditMeetupGeocodeCell.self)
    tableView.registerCell(EditMeetupDateCell.self)
    
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    dataSource = RxTableViewSectionedReloadDataSource(
      configureCell: { [weak self] dataSource, tableView, index, model in
        guard let this = self else { return UITableViewCell() }
        
        switch dataSource[index] {
        case let .name(_, label, placeholder):
          let cell = tableView.dequeueCell(ofType: EditMeetupTextFieldCell.self, for: index)
          cell.label.on(.next(label))
          cell.placeholder.on(.next(placeholder))
          
          cell.textValue
            .orEmpty
            .bind(to: this.viewModel.name)
            .disposed(by: this.disposeBag)
          
          return cell
        case let .description(_, label, placeholder):
          let cell = tableView.dequeueCell(ofType: EditMeetupTextViewCell.self, for: index)
          cell.placeholder.on(.next(placeholder))
          
          Observable.just(label).bind(to: cell.title).disposed(by: this.disposeBag)
          
          cell.textValue
            .bind(to: this.viewModel.description)
            .disposed(by: this.disposeBag)
          
          return cell
        case let .location(_, label):
          let cell = tableView.dequeueCell(ofType: EditMeetupGeocodeCell.self, for: index)
          cell.title.on(.next(label))
          
          this.viewModel.address
            .asObservable()
            .bind(to: cell.textFieldText)
            .disposed(by: this.disposeBag)
          
          return cell
        case let .startDate(_, label, startDate):
          let cell = tableView.dequeueCell(ofType: EditMeetupDateCell.self, for: index)
          cell.title.on(.next(label))
          cell.dateSubject.on(.next(startDate))
          
          cell.date
            .asObservable()
            .bind(to: this.viewModel.startDate)
            .disposed(by: this.disposeBag)
          
          return cell
        case let .endDate(_, label, endDate):
          let cell = tableView.dequeueCell(ofType: EditMeetupDateCell.self, for: index)
          cell.title.on(.next(label))
          cell.dateSubject.on(.next(endDate))
          
          cell.date
            .asObservable()
            .bind(to: this.viewModel.endDate)
            .disposed(by: this.disposeBag)
          
          return cell
        case let .other(_, label, notes):
          let cell = tableView.dequeueCell(ofType: EditMeetupTextViewCell.self, for: index)
          
          cell.placeholder.on(.next(notes))
          
          Observable.just(label)
            .bind(to: cell.title)
            .disposed(by: this.disposeBag)
          
          cell.textValue
            .map { text -> String? in
              let other = Other(notes: text)
              if let jsonData = try? JSONEncoder().encode(other) {
                let jsonString = String(data: jsonData, encoding: .utf8)
                return jsonString
              }
              return nil
            }
            .filterNil()
            .bind(to: this.viewModel.metadata)
            .disposed(by: this.disposeBag)
          
          cell.didBeginEditing
            .subscribe(onNext: { [weak self] in
              guard let this = self else { return }
              UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear], animations: {
                // kinda crap, but we'll use a default inset to scroll up to fix this
                let inset = CGPoint(x: 0, y: 140)
                this.tableView.setContentOffset(inset, animated: true)
              })
            })
            .disposed(by: this.disposeBag)
          
          cell.didEndEditing
            .subscribe(onNext: { [weak self] in
              guard let this = self else { return }
              UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear], animations: {
                // kinda crap, but we'll use a default inset to scroll up to fix this
                let inset = CGPoint(x: 0, y: 0)
                this.tableView.setContentOffset(inset, animated: true)
              })
            })
            .disposed(by: this.disposeBag)
          
          return cell
        }
      }
    )
    
    dataSource.titleForHeaderInSection = { _, _ in return "" }
    
    viewModel.meetupList
      .asObservable()
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    tableView.rx.modelSelected(EditMeetupViewModel.SectionItem.self)
      .subscribe(onNext: { [weak self] item in
        guard let this = self else { return }
        switch item {
        case .location:
          try? this.router.route(
            from: this,
            to: EditMeetupRouter.Routes.location.rawValue,
            parameters: ["viewModel": this.viewModel]
          )
        default:
          return
        }
      })
      .disposed(by: disposeBag)
    
  }
  
  private func prepareNavigationBar() {
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.blue.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    Observable.just("Edit Meetup")
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
    
    appBar.navigationBar.observe(navigationItem)
  }
  
  private func prepareNavigationCloseButton() {
    closeButton = UIBarButtonItem(
      image: UIImage(named: "ic_close")?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    
    closeButton.rx.tap
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.dismiss(animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    navigationItem.leftBarButtonItem = closeButton
  }
  
  private func prepareNavigationAddButton() {
    addButton = UIBarButtonItem(
      image: UIImage(named: "ic_done")?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    
    viewModel.submitButtonEnabled
      .bind(to: addButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    viewModel.submitButtonTap = addButton.rx.tap.asObservable()
    
    viewModel.submitButtonSuccess
      .asObservable()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let this = self else { return }
        let message = MDCSnackbarMessage(text: "Successfully edited meetup!")
        MDCSnackbarManager.show(message)
        this.viewModel.reloadMeetup.on(.next(()))
        this.dismiss(animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    viewModel.submitButtonFail
      .asObservable()
      .subscribe(onNext: { response in
        let message = MDCSnackbarMessage(text: response.reason)
        MDCSnackbarManager.show(message)
      })
      .disposed(by: disposeBag)
    
    viewModel.bindButtons()
    
    navigationItem.rightBarButtonItem = addButton
  }
  
  deinit {
    appBar.navigationBar.unobserveNavigationItem()
  }
}

//MARK: UITableViewDelegate
extension EditMeetupViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch dataSource[indexPath] {
    case .name:
      return 50
    case .description, .other:
      return 125
    default:
      return UITableViewAutomaticDimension
    }
  }
}

