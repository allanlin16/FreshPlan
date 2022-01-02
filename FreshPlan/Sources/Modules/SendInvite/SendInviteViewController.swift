//
//  SendInviteViewController.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2018-01-07.
//  Copyright © 2018 St Clair College. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxDataSources
import MaterialComponents

public final class SendInviteViewController: UIViewController {
  // MARK: Properties
  private var viewModel: SendInviteViewModelProtocol!
  
  // MARK: App Bar
  fileprivate let appBar = MDCAppBar()
  private var closeButton: UIBarButtonItem!
  private var sendButton: UIBarButtonItem!
  
  // MARK: Views
  private var tableView: UITableView!
  fileprivate var dataSource: RxTableViewSectionedAnimatedDataSource<SendInviteViewModel.Section>!
  
  private let disposeBag = DisposeBag()
  
  public convenience init(viewModel: SendInviteViewModel) {
    self.init(nibName: nil, bundle: nil)
    self.viewModel = viewModel
    
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
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    prepareView()
  }
  
  private func prepareView() {
    prepareTableView()
    prepareNavigationBar()
    prepareNavigationCloseButton()
    prepareNavigationSendButton()
    appBar.addSubviewsToParent()
  }
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.estimatedRowHeight = 70
    tableView.layoutMargins = .zero
    tableView.separatorInset = .zero
    tableView.separatorStyle = .singleLine
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
    tableView.registerCell(SendInviteMeetupCell.self)
    tableView.registerCell(SendInviteFriendCell.self)
    
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    dataSource = RxTableViewSectionedAnimatedDataSource<SendInviteViewModel.Section>(
      configureCell: { [weak self] dataSource, tableView, index, _ in
        guard let this = self else { fatalError() }
        switch dataSource[index] {
        case let .friend(_, displayName, email, checked):
          let cell = tableView.dequeueCell(ofType: SendInviteFriendCell.self, for: index)
          cell.displayName.onNext(displayName)
          cell.email.onNext(email)
          cell.checked.onNext(checked)
                    
          return cell
        case let .meetup(_, title, meetups):
          let cell = tableView.dequeueCell(ofType: SendInviteMeetupCell.self, for: index)
          cell.placeholder.onNext(title)
          cell.meetups.value = meetups
          
          cell.modelSelected
            .asObservable()
            .bind(to: this.viewModel.meetup)
            .disposed(by: this.disposeBag)
          
          return cell
        }
      }
    )
    
    dataSource.titleForHeaderInSection = { dataSource, index in
      return index == 0 ? "" : dataSource[index].title
    }
    
    dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .automatic, reloadAnimation: .automatic, deleteAnimation: .automatic)
    
    dataSource.canEditRowAtIndexPath = { dataSource, index in
      switch dataSource[index] {
      case .friend:
        return true
      default:
        return false
      }
    }
    
    viewModel.invites
      .asObservable()
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .asObservable()
      .filter { $0.section > 0 }
      .bind(to: viewModel.inviteClicked)
      .disposed(by: disposeBag)
  }
  
  private func prepareNavigationBar() {
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.blue.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    // set the nav bar title
    Observable.just("Send Invites")
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
    closeButton.tintColor = .white
    
    closeButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.dismiss(animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    navigationItem.leftBarButtonItem = closeButton
  }
  
  private func prepareNavigationSendButton() {
    sendButton = UIBarButtonItem(
      image: UIImage(named: "ic_send")?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    sendButton.tintColor = .white
    
    viewModel.addedInvites
      .asObservable()
      .map { $0.isNotEmpty }
      .bind(to: sendButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    sendButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.viewModel.sendInvite.onNext(())
      }).disposed(by: disposeBag)
    
    viewModel.sendInviteSuccess
      .asObservable()
      .take(1)
      .subscribe(onNext: { [weak self] count in
        self?.dismiss(animated: true, completion: {
          let message = MDCSnackbarMessage(text: "Sent out \(count) invites!")
          MDCSnackbarManager.show(message)
        })
      }).disposed(by: disposeBag)
    
    navigationItem.rightBarButtonItem = sendButton
  }
  
  deinit {
    appBar.navigationBar.unobserveNavigationItem()
  }
}

extension SendInviteViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch dataSource[indexPath] {
    case .friend:
      return UITableViewAutomaticDimension
    default:
      return 50
    }
  }
}
