//
//  LocationViewController.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-22.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit
import MaterialComponents
import CoreLocation
import MapKit

public final class LocationViewController: UIViewController {
  // MARK: Required
  private var viewModel: LocationViewModelProtocol!
  
  // MARK: Location
  public let locationManager: CLLocationManager = CLLocationManager()
  
  // MARK: AppBar
  fileprivate let appBar: MDCAppBar = MDCAppBar()
  private var searchBar: SearchBar!
  private var closeButton: UIBarButtonItem!
  
  // MARK: Views
  private var tableView: UITableView!
  private var emptyView: EmptyLocationView!
  
  private let disposeBag: DisposeBag = DisposeBag()
  
  public convenience init(viewModel: LocationViewModel) {
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
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    prepareLocation()
    prepareView()
  }
  
  private func prepareLocation() {
    locationManager.requestWhenInUseAuthorization()
    
    if CLLocationManager.authorizationStatus() == .authorizedWhenInUse, let location = locationManager.location {
      Observable.just(location.coordinate)
        .bind(to: viewModel.coordinate)
        .disposed(by: disposeBag)
    }
  }
  
  private func prepareView() {
    prepareTableView()
    prepareEmptyView()
    prepareSearchBar()
    prepareNavigationBar()
    prepareNavigationCloseButton()
    appBar.addSubviewsToParent()
  }
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.separatorInset = .zero
    tableView.layoutMargins = .zero
    tableView.estimatedRowHeight = 44
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.registerCell(LocationCell.self)
    
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    viewModel.locations
      .asObservable()
      .bind(to: tableView.rx.items(cellIdentifier: String(describing: LocationCell.self))) { [weak self] (row, element, cell) in
        guard let this = self else { fatalError() }
        cell.textLabel?.text = element.placemark.name
        cell.detailTextLabel?.text = this.parseAddress(element.placemark)
      }
      .disposed(by: disposeBag)
    
    tableView.rx.modelSelected(MKMapItem.self)
      .asObservable()
      .subscribe(onNext: { [weak self] mapItem in
        guard let this = self else { return }
        if let coordinate = mapItem.placemark.location?.coordinate, let name = mapItem.placemark.name {
          let location = Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
          guard let jsonData = try? JSONEncoder().encode(location) else { return }
          guard let jsonString = String(data: jsonData, encoding: .utf8) else { return }
          this.viewModel.updateMeetup.on(.next(jsonString))
          this.viewModel.updateAddress.on(.next(name))
          this.dismiss(animated: true, completion: nil)
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func prepareEmptyView() {
    emptyView = EmptyLocationView()
    
    view.addSubview(emptyView)
    
    emptyView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    viewModel.locations
      .asObservable()
      .map { $0.count == 0 }
      .bind(to: tableView.rx.isHidden)
      .disposed(by: disposeBag)
    
    viewModel.locations
      .asObservable()
      .map { $0.count > 0 }
      .bind(to: emptyView.rx.isHidden)
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
    
    Observable.just("Search for a location")
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
  
  private func prepareNavigationCloseButton() {
    closeButton = UIBarButtonItem(
      image: UIImage(named: "ic_close")?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    
    closeButton.rx.tap
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

    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    Observable.just("Search Place")
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
    
    appBar.navigationBar.observe(navigationItem)
  }
  
  /**
    Parses the address. This is actually really bad, I want to fix this at some point to be honest.
   **/
  fileprivate func parseAddress(_ mapItem: MKPlacemark) -> String {
    // put a space between "4" and "Melrose Place"
    let firstSpace = (mapItem.subThoroughfare != nil && mapItem.thoroughfare != nil) ? " " : ""
    // put a comma between street and city/state
    let comma = (mapItem.subThoroughfare != nil || mapItem.thoroughfare != nil) && (mapItem.subAdministrativeArea != nil || mapItem.administrativeArea != nil) ? ", " : ""
    // put a space between "Washington" and "DC"
    let secondSpace = (mapItem.subAdministrativeArea != nil && mapItem.administrativeArea != nil) ? " " : ""
    let addressLine = String(
      format:"%@%@%@%@%@%@%@",
      // street number
      mapItem.subThoroughfare ?? "",
      firstSpace,
      // street name
      mapItem.thoroughfare ?? "",
      comma,
      // city
      mapItem.locality ?? "",
      secondSpace,
      // state
      mapItem.administrativeArea ?? ""
    )
    return addressLine
  }
  
  deinit {
    appBar.navigationBar.unobserveNavigationItem()
  }
}
