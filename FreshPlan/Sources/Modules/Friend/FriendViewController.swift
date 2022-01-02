//
//  FriendViewController.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-08.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import UIKit
import MaterialComponents
import RxSwift
import RxDataSources

public class FriendViewController: UIViewController {
  // MARK: ViewModel, Router
  private var viewModel: FriendViewModelProtocol!
  
  // MARK: AppBar
  private let appBar: MDCAppBar = MDCAppBar()
  private var backButton: UIBarButtonItem!
  private var sendButton: UIBarButtonItem!
  
  // MARK: TableView
  private var tableView: UITableView!
  fileprivate var dataSource: RxTableViewSectionedReloadDataSource<FriendViewModel.Section>!
  
  // MARK: TapDelegate
  private var existingInteractivePopGestureRecognizerDelegate: UIGestureRecognizerDelegate?
  
  // MARK: DisposeBag
  private let disposeBag: DisposeBag = DisposeBag()
  
  public convenience init(viewModel: FriendViewModel) {
    self.init(nibName: nil, bundle: nil)
    self.viewModel = viewModel
    
    addChildViewController(appBar.headerViewController)
  }
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
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
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    prepareView()
  }
  
  private func prepareView() {
    prepareTableView()
    prepareNavigationBar()
    prepareNavigationBackButton()
    prepareNavigationSendButton()
    appBar.addSubviewsToParent()
  }
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.separatorStyle = .none
    tableView.estimatedRowHeight = 44
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
    tableView.registerCell(FriendProfileCell.self)
    tableView.registerCell(FriendInfoCell.self)
    
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    dataSource = RxTableViewSectionedReloadDataSource<FriendViewModel.Section>(
      configureCell: { (dataSource, tableView, index, section) in
        switch dataSource[index] {
        case let .info(_, type, title):
          let cell = tableView.dequeueCell(ofType: FriendInfoCell.self, for: index)
          cell.type.on(.next(type))
          cell.title.on(.next(title))
          return cell
        case let .profileTitle(_, profileURL, fullName):
          let cell = tableView.dequeueCell(ofType: FriendProfileCell.self, for: index)
          cell.profileUrl.on(.next(profileURL))
          cell.fullName.on(.next(fullName))
          return cell
        }
      }
    )
    
    dataSource.titleForHeaderInSection = { (dataSource, index) in
      return ""
    }
    
    viewModel.friendDetail
      .asObservable()
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }
  
  private func prepareNavigationBar() {
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.blue.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.headerViewController.headerView.maximumHeight = 76.0
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    viewModel.name
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
        this.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
    
    navigationItem.leftBarButtonItem = backButton
  }
  
  private func prepareNavigationSendButton() {
    sendButton = UIBarButtonItem(
      image: UIImage(named: "ic_send")?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    
    viewModel.tapSend = sendButton.rx.tap.asObservable()
    
    viewModel.disabledSend
      .asObservable()
      .bind(to: sendButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    viewModel.sendFriend
      .asObservable()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        self?.navigationController?.popViewController(animated: true)
        let message = MDCSnackbarMessage(text: "Successfully sent friend request!")
        MDCSnackbarManager.show(message)
      })
      .disposed(by: disposeBag)
  
    navigationItem.rightBarButtonItem = sendButton
    
    viewModel.bindButtons()
  }
  
  deinit {
    appBar.navigationBar.unobserveNavigationItem()
  }
}

//MARK: TableViewDelegate
extension FriendViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch dataSource[indexPath] {
    case .profileTitle:
      return 120
    default:
      return UITableViewAutomaticDimension
    }
  }
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView == appBar.headerViewController.headerView.trackingScrollView {
      appBar.headerViewController.headerView.trackingScrollDidScroll()
    }
  }
  
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if scrollView == appBar.headerViewController.headerView.trackingScrollView {
      appBar.headerViewController.headerView.trackingScrollDidEndDecelerating()
    }
  }
}
