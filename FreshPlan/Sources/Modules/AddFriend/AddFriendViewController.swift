//
//  AddFriendViewController.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-03.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit
import MaterialComponents

public final class AddFriendViewController: UIViewController {
  // MARK:  ViewModel
  private var viewModel: AddFriendViewModelProtocol!
  private var router: AddFriendRouter!
  
  // MARK:  AppBar
  fileprivate var appBar: MDCAppBar = MDCAppBar()
  private var closeButton: UIBarButtonItem!
  
  // MARK:  TableView
  private var containerView: UIView!
  private var searchBar: SearchBar!
  private var tableView: UITableView!
  private var emptyView: EmptyView!
  
  // MARK:  DisposeBag
  private var disposeBag: DisposeBag = DisposeBag()
  
  public convenience init(viewModel: AddFriendViewModel, router: AddFriendRouter) {
    self.init(nibName: nil, bundle: nil)
    self.viewModel = viewModel
    self.router = router
    
    addChildViewController(appBar.headerViewController)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nil, bundle: nil)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    prepareView()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // disables the default nav bar for that user
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  public override var childViewControllerForStatusBarStyle: UIViewController? {
    return appBar.headerViewController
  }
 
  private func prepareView() {
    prepareTableView()
    prepareEmptyView()
    prepareNavigationBar()
    prepareNavigationAdd()
    prepareSearchBar()
    appBar.addSubviewsToParent()
  }
  
  private func prepareEmptyView() {
    emptyView = EmptyView()
    
    view.addSubview(emptyView)
    
    emptyView.snp.makeConstraints { $0.edges.equalTo(view) }
    
    viewModel.friends
      .asObservable()
      .map { $0.count > 0 }
      .bind(to: emptyView.rx.isHidden)
      .disposed(by: disposeBag)
    
    viewModel.friends
      .asObservable()
      .map { $0.count == 0 }
      .bind(to: tableView.rx.isHidden)
      .disposed(by: disposeBag)
  }
  
  private func prepareSearchBar() {
    //: TODO - Fix searchbar sizing on navigation bar
    searchBar = SearchBar()
    
    // we'll make a check for ios 11    
    searchBar.rx.text
      .orEmpty
      .bind(to: viewModel.searchText)
      .disposed(by: disposeBag)
    
    Observable.just("Search for friends")
      .bind(to: searchBar.rx.placeholder)
      .disposed(by: disposeBag)
    
    searchBar.rx.searchButtonClicked
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.searchBar.resignFirstResponder()
      })
      .disposed(by: disposeBag)
    
    appBar.headerStackView.bottomBar = searchBar
  }
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.estimatedRowHeight = 44
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
    tableView.registerCell(FriendCell.self)
    
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { $0.edges.equalTo(view) }
    
    // we want to check for the tableviews.
    viewModel.friends
      .asObservable()
      .bind(to: tableView.rx.items(cellIdentifier: String(describing: FriendCell.self))) { (index, friend, cell) in
        cell.textLabel?.text = friend.displayName
      }
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .asObservable()
      .map { [weak self] index in self?.viewModel.friends.value[index.row] }
      .filterNil()
      .subscribe(onNext: { [weak self] friend in
        // create a strong reference and route
        if let this = self {
          try? this.router.route(
            from: this,
            to: AddFriendRouter.Routes.friend.rawValue,
            parameters: ["friendId": friend.id]
          )
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func prepareNavigationAdd() {
    closeButton = UIBarButtonItem(
      image: UIImage(named: "ic_close")?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    
    // setup the rx event
    closeButton.rx.tap
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.dismiss(animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    navigationItem.leftBarButtonItem = closeButton
  }
  
  private func prepareNavigationBar() {
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.blue.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.headerViewController.headerView.maximumHeight = 120
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    Observable.just("Friends Search")
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
    
    // table stuff
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    // set layout margins to fix
    tableView.layoutMargins = UIEdgeInsets.zero
    tableView.separatorInset = UIEdgeInsets.zero
    
    appBar.navigationBar.observe(navigationItem)
  }
  
  deinit {
    appBar.navigationBar.unobserveNavigationItem()
  }
}

// MARK:  TableViewDelegate
extension AddFriendViewController: UITableViewDelegate {
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
