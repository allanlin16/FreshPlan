//
//  InviteViewController.swift
//  FreshPlan
//
//  Created by Allan Lin on 2017-12-10.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import UIKit
import MaterialComponents
import RxSwift
import RxDataSources
import SnapKit

public final class InviteViewController: UIViewController {
  // MARK: ViewModel
  private var viewModel: InviteViewModelProtocol!
  private var router: InviteRouter!
  
  // MARKa: dataSource
  fileprivate var dataSource: RxTableViewSectionedAnimatedDataSource<InviteViewModel.Section>!
  
  // MARK: AppBar
  fileprivate var appBar: MDCAppBar = MDCAppBar()
  private var addButton: UIBarButtonItem!
  
  // MARK: EmptyView
  private var emptyInviteView: EmptyInvitationView!
  
  //MARK: TableView
  private var tableView: UITableView!
  
  // MARK:  DisposeBag
  private var disposeBag: DisposeBag = DisposeBag()
  
  private var refreshControl: UIRefreshControl!
  
  public convenience init(viewModel: InviteViewModel, router: InviteRouter) {
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
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    prepareView()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  public override var childViewControllerForStatusBarStyle: UIViewController? {
    return appBar.headerViewController
  }
  
  public func prepareView() {
    prepareRefreshControl()
    prepareTableView()
    prepareEmptyInviteView()
    prepareNavigationBar()
    prepareNavigationAddButton()
    appBar.addSubviewsToParent()
  }
  
  // TableView
  private func prepareTableView() {
    tableView = UITableView()
    tableView.refreshControl = refreshControl
    tableView.separatorStyle = .singleLine
    tableView.separatorInset = .zero
    tableView.layoutMargins = .zero
    tableView.rowHeight = 80
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
    tableView.registerCell(InviteCell.self)
    
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints{ $0.edges.equalTo(view) }
    
    dataSource = RxTableViewSectionedAnimatedDataSource(
      configureCell: { dataSource, tableView, index, model in
        let cell = tableView.dequeueCell(ofType: InviteCell.self, for: index)
        cell.meetupName.on(.next(dataSource[index].meetupName))
        cell.inviter.on(.next(dataSource[index].inviter.displayName))
        cell.startDate.on(.next(dataSource[index].meetupStartDate))
        cell.endDate.on(.next(dataSource[index].meetupEndDate))
        return cell
      }
    )
    
    dataSource.titleForHeaderInSection = { _, _ in return "" }
    
    dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .automatic, reloadAnimation: .automatic, deleteAnimation: .automatic)
    
    dataSource.canEditRowAtIndexPath = { _, _ in
      return true
    }
    
    viewModel.acceptInvitaionSuccess
      .asObservable()
      .filterNil()
      .subscribe(onNext: { displayName in
        let message = MDCSnackbarMessage(text: "Successfully accepted Invitation for \(displayName).")
        MDCSnackbarManager.show(message)
      })
      .disposed(by: disposeBag)
    
    viewModel.declineInvitationSuccess
      .asObservable()
      .filterNil()
      .subscribe(onNext: { displayName in
        let message = MDCSnackbarMessage(text: "Successfully declined Invitation for \(displayName).")
        MDCSnackbarManager.show(message)
      })
      .disposed(by: disposeBag)
    
    viewModel.invitations
      .asObservable()
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
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
  
  // EmptyInviteView
  private func prepareEmptyInviteView() {
    emptyInviteView = EmptyInvitationView()
    
    tableView.backgroundView = emptyInviteView
    
    emptyInviteView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    viewModel.invitations
      .asObservable()
      .filter { $0.isNotEmpty && $0[0].items.isEmpty }
      .subscribe(onNext: { [weak self] _ in
        guard let this = self else { return }
        this.tableView.separatorStyle = .none
        this.tableView.backgroundView?.isHidden = false
      })
      .disposed(by: disposeBag)
    
    viewModel.invitations
      .asObservable()
      .filter { $0.isNotEmpty && $0[0].items.isNotEmpty }
      .subscribe(onNext: { [weak self] _ in
        guard let this = self else { return }
        this.tableView.separatorStyle = .singleLine
        this.tableView.backgroundView?.isHidden = true
      })
      .disposed(by: disposeBag)
  }
  
  private func prepareNavigationBar() {
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.blue.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    // set the nav bar title
    Observable.just("My Invitations")
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
    
    appBar.navigationBar.observe(navigationItem)
    
  }
  
  private func prepareNavigationAddButton() {
    addButton = UIBarButtonItem(
      image: UIImage(named: "ic_add")?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    addButton.tintColor = .white
    
    addButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        try? this.router.route(
          from: this,
          to: InviteRouter.Routes.sendInvite.rawValue,
          parameters: nil
        )
      })
      .disposed(by: disposeBag)
    
    navigationItem.rightBarButtonItem = addButton
  }
  
  deinit {
    appBar.navigationBar.unobserveNavigationItem()
  }
}

// MARK:  TableViewDelegate
extension InviteViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let acceptInvite = UITableViewRowAction(
      style: .normal,
      title: "Accept",
      handler: { [weak self] _, index in
        guard let this = self else { return }
        this.viewModel.acceptInvitation.on(.next(index))
      }
    )
    let declineInvite = UITableViewRowAction(
      style: .normal,
      title: "Decline",
      handler: { [weak self] _, index in
        guard let this = self else { return }
        this.viewModel.declineInvitation.on(.next(indexPath))
      }
    )
    acceptInvite.backgroundColor = MDCPalette.green.tint400
    declineInvite.backgroundColor = MDCPalette.red.tint400
    return [declineInvite, acceptInvite]
  }
}
