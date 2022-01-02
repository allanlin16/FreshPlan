//
//  ProfileViewController.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-11-16.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import RxSwift
import RxOptional
import RxDataSources
import MaterialComponents

public final class ProfileViewController: UIViewController {
  // MARK: Profile View Model and Router
  private var viewModel: ProfileViewModelProtocol!
  private var router: ProfileRouter!
  
  // MARK: AppBar
  private let appBar: MDCAppBar = MDCAppBar()
  
  // MARK: DisposeBag
  private let disposeBag: DisposeBag = DisposeBag()
  
  // MARK: TableView
  private var tableView: UITableView!
  private var refreshControl: UIRefreshControl!
  fileprivate var dataSource: RxTableViewSectionedReloadDataSource<ProfileViewModel.SectionModel>!
  
  // MARK: Nav Buttons
  private var searchButton: UIBarButtonItem!
  private var logoutButton: UIBarButtonItem!
  
  public convenience init(viewModel: ProfileViewModel, router: ProfileRouter) {
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
    
    navigationController?.setNavigationBarHidden(true, animated: animated)
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
    prepareNavigationSearchButton()
    prepareNavigationLogoutButton()
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
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        if let this = self {
          this.refreshControl.endRefreshing()
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func prepareNavigationLogoutButton() {
    // for now we'll just remove the token, but it's highly recommended I think to use a route
    // TODO: use the route to logout for better access
    logoutButton = UIBarButtonItem(title: "Log out", style: .plain, target: nil, action: nil)
    
    logoutButton.rx.tap
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        // we can just create a modal in here and attempt to log out
        let alertController = MDCAlertController(title: "Are you sure you want to log out?", message: "Hit confirm, if you would like to log out")
        let confirm = MDCAlertAction(title: "Confirm") { _ in
          try? this.router.route(from: this, to: ProfileRouter.Routes.logout.rawValue)
        }
        alertController.addAction(confirm)
        alertController.addAction(MDCAlertAction(title: "Cancel"))
        this.present(alertController, animated: true, completion: nil)
      })
    .disposed(by: disposeBag)
    
    navigationItem.rightBarButtonItem = logoutButton
  }
  
  private func prepareNavigationSearchButton() {
    searchButton = UIBarButtonItem(
      image: UIImage(named: "ic_search")?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    
    // setup the rx event
    searchButton.rx.tap
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        try? this.router.route(
          from: this,
          to: ProfileRouter.Routes.addFriend.rawValue
        )
      })
      .disposed(by: disposeBag)
    
    navigationItem.leftBarButtonItem = searchButton
  }
  
  private func prepareNavigationBar() {
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.blue.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    Observable.just("Profile")
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
    
    appBar.navigationBar.observe(navigationItem)
  }
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.refreshControl = refreshControl
    tableView.estimatedRowHeight = 44
    tableView.separatorStyle = .singleLine
    tableView.separatorInset = .zero
    tableView.layoutMargins = .zero
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
    tableView.registerCell(ProfileUserHeaderCell.self)
    tableView.registerCell(ProfileUserInfoCell.self)
    tableView.registerCell(ProfileFriendCell.self)
    
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    // set up data sources
    dataSource = RxTableViewSectionedReloadDataSource<ProfileViewModel.SectionModel>(
      configureCell: { (dataSource, table, index, _) in
        switch dataSource[index] {
        case let .profile(_, profileURL, fullName):
          let cell = table.dequeueCell(ofType: ProfileUserHeaderCell.self, for: index)
          cell.fullName.on(.next(fullName))
          cell.profileURL.on(.next(profileURL))
          return cell
        case let .displayName(_, title, name):
          let cell = table.dequeueCell(ofType: ProfileUserInfoCell.self, for: index)
          cell.title.on(.next(title))
          cell.info.on(.next(name))
          return cell
        case let .email(_, title, description):
          let cell = table.dequeueCell(ofType: ProfileUserInfoCell.self, for: index)
          cell.title.on(.next(title))
          cell.info.on(.next(description))
          return cell
        case let .joined(_, title, description):
          let cell = table.dequeueCell(ofType: ProfileUserInfoCell.self, for: index)
          cell.title.on(.next(title))
          cell.info.on(.next(description))
          return cell
        case let .friend(_, displayName):
          let cell = table.dequeueCell(ofType: ProfileFriendCell.self, for: index)
          cell.title.on(.next(displayName))
          return cell
        }
    })
    
    dataSource.canEditRowAtIndexPath = { dataSource, index in
      switch dataSource.sectionModels[index.section] {
      case .friendRequests, .friends:
        return true
      default:
        return false
      }
    }
    
    dataSource.titleForHeaderInSection = { dataSource, index in
      return index == 0 ? "" : dataSource[index].title
    }
    
    dataSource.rowAnimation = .automatic
    
    viewModel.profileItems
      .asObservable()
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    viewModel.acceptedFriendSuccess
      .asObservable()
      .filterNil()
      .subscribe(onNext: { displayName in
        let message = MDCSnackbarMessage(text: "Successfully added \(displayName) as a friend.")
        MDCSnackbarManager.show(message)
      })
      .disposed(by: disposeBag)
    
    viewModel.removeFriendSuccess
      .asObservable()
      .filterNil()
      .subscribe(onNext: { displayName in
        let message = MDCSnackbarMessage(text: "Successfully removed \(displayName)")
        MDCSnackbarManager.show(message)
      })
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .asObservable()
      .subscribe(onNext: { [weak self] index in
        if let this = self {
          switch this.dataSource[index] {
          case let .friend(id, _):
            try? this.router.route(
              from: this,
              to: ProfileRouter.Routes.friend.rawValue,
              parameters: ["friendId": id]
            )
          default:
            break
          }
        }
      })
      .disposed(by: disposeBag)
  }
  
  deinit {
    appBar.navigationBar.unobserveNavigationItem()
  }
}

// MARK:  UIScrollViewDelegate
extension ProfileViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    switch dataSource.sectionModels[indexPath.section] {
    case .friendRequests:
      let friendSwipeAccept = UITableViewRowAction(
        style: .normal,
        title: "Accept Friend Request",
        handler: { [weak self] _, index in
          guard let this = self else { return }
          this.viewModel.acceptFriend.on(.next(index))
        }
      )
      friendSwipeAccept.backgroundColor = MDCPalette.green.tint400
      return [friendSwipeAccept]
    case .friends:
      let friendDelete = UITableViewRowAction(
        style: .destructive,
        title: "Remove Friend",
        handler: { [weak self] _, index in
          guard let this = self else { return }
          this.viewModel.removeFriend.on(.next(index))
        }
      )
      return [friendDelete]
    default:
      return nil
    }
  }
  
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch dataSource[indexPath] {
    case .profile:
      return 70
    default:
      return UITableViewAutomaticDimension
    }
  }
}
