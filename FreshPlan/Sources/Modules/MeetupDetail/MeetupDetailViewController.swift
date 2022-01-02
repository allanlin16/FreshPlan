//
//  MeetupDetailViewController.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-17.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import RxOptional
import RxSwift
import RxDataSources
import SnapKit
import MaterialComponents

public class MeetupDetailViewController: UIViewController {
  //MARK: UIView
  private var viewModel: MeetupDetailViewModelProtocol!
  private var router: MeetupDetailRouter!
  
  //MARK: AppBar
  private let appBar: MDCAppBar = MDCAppBar()
  private var backButton: UIBarButtonItem!
  private var editButton: UIBarButtonItem!
  
  //MARK: TableView
  private var tableView: UITableView!
  private var dataSource: RxTableViewSectionedReloadDataSource<MeetupDetailViewModel.Section>!
  private var refreshControl: UIRefreshControl!
  
  // MARK: Gesture
  private var existingInteractivePopGestureRecognizerDelegate: UIGestureRecognizerDelegate?
  
  private let disposeBag: DisposeBag = DisposeBag()
  
  public convenience init(viewModel: MeetupDetailViewModel, router: MeetupDetailRouter) {
    self.init(nibName: nil, bundle: nil)
    self.viewModel = viewModel
    self.router = router
    
    addChildViewController(appBar.headerViewController)
  }
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setNeedsStatusBarAppearanceUpdate()
    
    // Hold reference to current interactivePopGestureRecognizer delegate
    if let delegate = navigationController?.interactivePopGestureRecognizer?.delegate {
      existingInteractivePopGestureRecognizerDelegate = delegate
    }
    
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // Set interactivePopGestureRecognizer delegate to nil
    navigationController?.interactivePopGestureRecognizer?.delegate = nil
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Return interactivePopGestureRecognizer delegate to previously held object
    if let delegate = existingInteractivePopGestureRecognizerDelegate {
      navigationController?.interactivePopGestureRecognizer?.delegate = delegate
    }
  }
  
  public override var childViewControllerForStatusBarStyle: UIViewController? {
    return appBar.headerViewController
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    prepareView()
  }
  
  private func prepareView() {
    prepareRefreshControl()
    prepareTableView()
    prepareNavigationBar()
    prepareNavigationBackButton()
    prepareNavigationDeleteButton()
    appBar.addSubviewsToParent()
  }
  
  private func prepareRefreshControl() {
    refreshControl = UIRefreshControl()
    
    refreshControl.rx.controlEvent(.valueChanged)
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.viewModel.refreshContent.on(.next(()))
      })
      .disposed(by: disposeBag)
    
    viewModel.refreshSuccess
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.refreshControl.endRefreshing()
      })
      .disposed(by: disposeBag)
  }
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.refreshControl = refreshControl
    tableView.separatorInset = .zero
    tableView.estimatedRowHeight = 44
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.tableFooterView = UIView(frame: .zero)
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
    tableView.registerCell(MeetupTitleCell.self)
    tableView.registerCell(MeetupDescriptionCell.self)
    tableView.registerCell(MeetupLocationCell.self)
    tableView.registerCell(MeetupDirectionCell.self)
    tableView.registerCell(MeetupInviteCell.self)
    tableView.registerCell(MeetupNoteCell.self)
    
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    // configure dataSource
    dataSource = RxTableViewSectionedReloadDataSource<MeetupDetailViewModel.Section>(
      configureCell: { (dataSource, tableView, index, section) in
      switch dataSource[index] {
      case let .title(_, host, startDate, endDate):
        let cell = tableView.dequeueCell(ofType: MeetupTitleCell.self, for: index)
        cell.title.on(.next(host))
        cell.startDate.on(.next(startDate))
        cell.endDate.on(.next(endDate))
        return cell
      case let .desc(_, description):
        let cell = tableView.dequeueCell(ofType: MeetupDescriptionCell.self, for: index)
        cell.descriptionText.on(.next(description))
        return cell
      case let .location(_, title, latitude, longitude):
        let cell = tableView.dequeueCell(ofType: MeetupLocationCell.self, for: index)
        cell.title.on(.next(title))
        cell.latitude.on(.next(latitude))
        cell.longitude.on(.next(longitude))
        return cell
      case let .directions(_, text, _, _):
        let cell = tableView.dequeueCell(ofType: MeetupDirectionCell.self, for: index)
        cell.title.on(.next(text))
        return cell
      case let .invitations(_, _, invitee, accepted):
        let cell = tableView.dequeueCell(ofType: MeetupInviteCell.self, for: index)
        cell.displayName.on(.next(invitee))
        cell.accepted.on(.next(accepted))
        return cell
      case let .other(_, notes):
        let cell = tableView.dequeueCell(ofType: MeetupNoteCell.self, for: index)
        cell.note.on(.next(notes))
        return cell
      }
    })
    
    dataSource.titleForHeaderInSection = { dataSource, index in
      return index == 0 ? "" : dataSource[index].title
    }
    
    tableView.rx.modelSelected(MeetupDetailViewModel.SectionItem.self)
      .subscribe(onNext: { [weak self] item in
        guard let this = self else { return }
        switch item {
        case let .directions(_, _, latitude, longitude):
          try? this.router.route(
            from: this,
            to: MeetupDetailRouter.Routes.googlemaps.rawValue,
            parameters: [
              "latitude": latitude,
              "longitude": longitude
            ]
          )
        case let .invitations(_, inviteeId, _, _):
          try? this.router.route(
            from: this,
            to: MeetupDetailRouter.Routes.invitee.rawValue,
            parameters: [
              "inviteeId": inviteeId
            ]
          )
        default:
          return
        }
      })
      .disposed(by: disposeBag)
    
    viewModel.section
      .asObservable()
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }
  
  private func prepareNavigationBar() {
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.blue.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    viewModel.title
      .asObservable()
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
    
    appBar.navigationBar.observe(navigationItem)
  }
  
  private func prepareNavigationBackButton() {
    backButton = UIBarButtonItem(
      image: UIImage(named: "ic_arrow_back")?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    
    backButton.rx.tap
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        try? this.router.route(
          from: this,
          to: MeetupDetailRouter.Routes.meetup.rawValue
        )
      })
      .disposed(by: disposeBag)
    
    navigationItem.leftBarButtonItem = backButton
  }
  
  private func prepareNavigationDeleteButton() {
    editButton = UIBarButtonItem(title: "Edit", style: .plain, target: nil, action: nil)
    
    viewModel.canEdit
      .bind(to: editButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    editButton.rx.tap
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        try? this.router.route(
          from: this,
          to: MeetupDetailRouter.Routes.editMeetup.rawValue,
          parameters: ["meetupId": this.viewModel.meetupId, "viewModel": this.viewModel]
        )
      })
      .disposed(by: disposeBag)
    
    navigationItem.rightBarButtonItem = editButton
  }
  
  deinit {
    appBar.navigationBar.unobserveNavigationItem()
  }
}

//MARK: TableViewDelegate
extension MeetupDetailViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch dataSource[indexPath] {
    case .location:
      return 325
    default:
      return UITableViewAutomaticDimension
    }
  }
}

