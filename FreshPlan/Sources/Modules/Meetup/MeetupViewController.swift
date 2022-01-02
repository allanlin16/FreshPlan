//
//  MeetupController.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-10-13.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import UIKit
import MaterialComponents
import RxSwift
import RxDataSources
import SnapKit

public final class MeetupViewController: UIViewController {
	private var viewModel: MeetupViewModelProtocol!
	private var router: MeetupRouter!
  
  //MARK: views
  private var emptyMeetupView: EmptyMeetupView!
  private var tableView: UITableView!
  fileprivate var dataSource: RxTableViewSectionedAnimatedDataSource<MeetupViewModel.Section>!
  private var refreshControl: UIRefreshControl!
  
  //MARK: App Bar
  fileprivate let appBar: MDCAppBar = MDCAppBar()
  private var addButton: UIBarButtonItem!
  
  //MARK: DisposeBag
  private let disposeBag: DisposeBag = DisposeBag()
	
	public convenience init(viewModel: MeetupViewModel, router: MeetupRouter) {
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
  
  public override var childViewControllerForStatusBarStyle: UIViewController? {
    return appBar.headerViewController
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
    prepareRefreshControl()
    prepareTableView()
    prepareEmptyMeetupView()
    prepareNavigationBar()
    prepareNavigationAddButton()
    appBar.addSubviewsToParent()
  }
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.refreshControl = refreshControl
    tableView.separatorStyle = .singleLine
    tableView.separatorInset = .zero
    tableView.layoutMargins = .zero
    tableView.rowHeight = 80
    tableView.registerCell(MeetupCell.self)
    
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    dataSource = RxTableViewSectionedAnimatedDataSource(
      configureCell: { dataSource, tableView, index, model in
        let cell = tableView.dequeueCell(ofType: MeetupCell.self, for: index)
        cell.name.on(.next(model.title))
        cell.startDate.on(.next(model.startDate))
        cell.endDate.on(.next(model.endDate))
        return cell
      }
    )
    
    dataSource.titleForHeaderInSection = { _,_ in return "" }
    
    dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .automatic, reloadAnimation: .automatic, deleteAnimation: .automatic)
    
    dataSource.canEditRowAtIndexPath = { _, _ in
      return true
    }
    
    viewModel.meetups
      .asObservable()
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    tableView.rx.modelSelected(Meetup.self)
      .asObservable()
      .subscribe(onNext: { [weak self] meetup in
        if let this = self {
          try? this.router.route(
            from: this,
            to: MeetupRouter.Routes.meetup.rawValue,
            parameters: ["meetupId": meetup.id]
          )
        }
      })
      .disposed(by: disposeBag)
    
    viewModel.itemDeleted = tableView.rx.itemDeleted.asObservable()
    
    viewModel.authCheck
      .filter { !$0 }
      .subscribe(onNext: { _ in
        let message = MDCSnackbarMessage(text: "Unable to delete meetup!")
        MDCSnackbarManager.show(message)
      })
      .disposed(by: disposeBag)
    
    viewModel.authCheck
      .filter { $0 }
      .subscribe(onNext: { _ in
        let message = MDCSnackbarMessage(text: "Successfully removed meetup!")
        MDCSnackbarManager.show(message)
      })
      .disposed(by: disposeBag)
    
    viewModel.bindButtons()
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
  
  private func prepareEmptyMeetupView() {
    emptyMeetupView = EmptyMeetupView()
    
    tableView.backgroundView = emptyMeetupView
    
    emptyMeetupView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    viewModel.meetups
      .asObservable()
      .filter { $0.isNotEmpty && $0[0].items.isEmpty }
      .subscribe(onNext: { [weak self] _ in
        guard let this = self else { return }
        this.tableView.separatorStyle = .none
        this.tableView.backgroundView?.isHidden = false
      })
      .disposed(by: disposeBag)

    viewModel.meetups
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
    
    Observable.just("Meetup")
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
    
    addButton.rx.tap
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        try? this.router.route(
          from: this,
          to: MeetupRouter.Routes.addMeetupOption.rawValue,
          parameters: ["viewModel": this.viewModel]
        )
      })
      .disposed(by: disposeBag)
    
    navigationItem.rightBarButtonItem = addButton
  }
  
  deinit {
    appBar.navigationBar.unobserveNavigationItem()
  }
}
