//
//  SettingsViewController.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-28.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import RxSwift
import SnapKit
import RxDataSources
import MaterialComponents

public final class SettingsViewController: UIViewController {
  // MARK: Properties
  private var viewModel: SettingsViewModelProtocol!
  
  // MARK: Views
  private var tableView: UITableView!
  private var dataSource: RxTableViewSectionedReloadDataSource<SettingsViewModel.Section>!
  
  //MARK: AppBar
  private let appBar: MDCAppBar = MDCAppBar()
  
  
  private let disposeBag: DisposeBag = DisposeBag()
  
  public convenience init(viewModel: SettingsViewModel) {
    self.init(nibName: nil, bundle: nil)
    self.viewModel = viewModel
    
    addChildViewController(appBar.headerViewController)
  }
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  public override var childViewControllerForStatusBarStyle: UIViewController? {
    return appBar.headerViewController
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    prepareView()
  }
  
  private func prepareView() {
    prepareTableView()
    prepareNavigationBar()
    appBar.addSubviewsToParent()
  }
  
  private func prepareTableView() {
    // set layout margins to fix
    tableView = UITableView(frame: .zero, style: .grouped)
    tableView.registerCell(SettingsCell.self)
    tableView.registerCell(SettingsSwitchCell.self)
    
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    // set up the data Soruce
    dataSource = RxTableViewSectionedReloadDataSource<SettingsViewModel.Section>(
      configureCell: { [weak self] (dataSource, tableView, index, _) in
        guard let this = self else { fatalError() }
        
        switch dataSource[index] {
        case let .build(_, title, build):
          let cell = tableView.dequeueCell(ofType: SettingsCell.self, for: index)
          cell.title.on(.next(title))
          cell.subtitle.on(.next(build))
          return cell
        case let .version(_, title, version):
          let cell = tableView.dequeueCell(ofType: SettingsCell.self, for: index)
          cell.title.on(.next(title))
          cell.subtitle.on(.next(version))
          return cell
        case let .license(_, title):
          let cell = tableView.dequeueCell(ofType: SettingsCell.self, for: index)
          cell.title.on(.next(title))
          cell.accessoryType = .disclosureIndicator
          return cell
        case let .report(_, title):
          let cell = tableView.dequeueCell(ofType: SettingsCell.self, for: index)
          cell.title.on(.next(title))
          return cell
        case let .featureRequest(_, title):
          let cell = tableView.dequeueCell(ofType: SettingsCell.self, for: index)
          cell.title.on(.next(title))
          return cell
        case let .notifications(_, title, enabled):
          let cell = tableView.dequeueCell(ofType: SettingsSwitchCell.self, for: index)
          cell.title.on(.next(title))
          cell.enabled.on(.next(enabled))
          
          this.viewModel.switchSelected = cell.isSwitchOn
          this.viewModel.bindCell()
          
          return cell
        }
      }
    )
    
    dataSource.titleForHeaderInSection = { dataSource, index in
      return dataSource[index].title
    }
    
    // Bind the calls
    viewModel.modelSelected = tableView.rx.modelSelected(SettingsViewModel.SectionItem.self).asObservable()
    viewModel.bindButtons()
    
    viewModel.switchSuccessAdd
      .asObservable()
      .filter { $0 }
      .subscribe(onNext: { _ in
        let message = MDCSnackbarMessage(text: "Linked Push Notifications to this account")
        MDCSnackbarManager.show(message)
      })
      .disposed(by: disposeBag)
    
    viewModel.switchSuccessAdd
      .asObservable()
      .filter { !$0 }
      .subscribe(onNext: { _ in
        let message = MDCSnackbarMessage(text: "There may be an existing account linked to this device for push notifications.")
        MDCSnackbarManager.show(message)
      })
      .disposed(by: disposeBag)
    
    viewModel.switchRemoveSuccess
      .asObservable()
      .filter { $0 }
      .subscribe(onNext: { _ in
        let message = MDCSnackbarMessage(text: "Removed Push Notifications")
        MDCSnackbarManager.show(message)
      })
      .disposed(by: disposeBag)
    
    viewModel.sendEmail
      .asObservable()
      .subscribe(onNext: { [weak self] email in
        guard let this = self else { return }
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = this
        composeVC.setToRecipients([email.recipient])
        composeVC.setCcRecipients([email.cc])
        composeVC.setSubject(email.subject)

        this.present(composeVC, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    viewModel.canSendMail
      .subscribe(onNext: {
        let message = MDCSnackbarMessage(text: "Can't open mail!")
        MDCSnackbarManager.show(message)
      })
      .disposed(by: disposeBag)
    
    viewModel.settings
      .asObservable()
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }
  
  private func prepareNavigationBar() {
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.blue.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    Observable.just("Settings")
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
    
    // table stuff
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    appBar.navigationBar.observe(navigationItem)
  }
  
  deinit {
    appBar.navigationBar.unobserveNavigationItem()
  }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
  public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    // let's check our result
    if result == .sent {
      let message = MDCSnackbarMessage(text: "Successfully sent email message to the developers!")
      MDCSnackbarManager.show(message)
    } else if result == .failed || result == .cancelled {
      let message = MDCSnackbarMessage(text: "Could not send mail! Are you connected to the internet?")
      MDCSnackbarManager.show(message)
    }
    
    controller.dismiss(animated: true, completion: nil)
  }
}
