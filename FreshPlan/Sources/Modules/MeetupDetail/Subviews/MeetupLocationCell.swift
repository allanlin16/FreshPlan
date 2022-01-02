//
//  MeetupLocationCell.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-21.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import RxSwift
import RxOptional
import MaterialComponents

public final class MeetupLocationCell: UITableViewCell {
  // MARK: PublishSubjects
  public var title: PublishSubject<String> = PublishSubject()
  public var latitude: PublishSubject<Double> = PublishSubject()
  public var longitude: PublishSubject<Double> = PublishSubject()
  
  // MARK: Variables
  private var placemarkName: Variable<String> = Variable("")
  
  // MARK: - MapViews
  private var mapView: MKMapView!
  private var locationManager: CLLocationManager!
  
  private let disposeBag: DisposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func prepareView() {
    selectionStyle = .none
    prepareLocationManager()
    prepareMapView()
  }
  
  private func prepareLocationManager() {
    locationManager = CLLocationManager()
    locationManager.requestWhenInUseAuthorization()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
  }
  
  private func prepareMapView() {
    mapView = MKMapView()
    mapView.delegate = self
    mapView.showsUserLocation = true
    // deal with the scale
    if #available(iOS 11.0, *) {
      let scale = MKScaleView(mapView: mapView)
      scale.scaleVisibility = .visible // always visible
      contentView.addSubview(scale)
    }
    
    contentView.addSubview(mapView)
    
    mapView.snp.makeConstraints { make in
      make.edges.equalTo(contentView)
    }
  
    let coords = Observable.zip(title.asObservable(), latitude.asObservable(), longitude.asObservable())
      .share()
    
    coords
      .map { CLLocation(latitude: $0.1, longitude: $0.2) }
      .flatMap { CLGeocoder().rx.reverseGeocodeLocation(location: $0) }
      .map { $0[0].name }
      .filterNil()
      .bind(to: placemarkName)
      .disposed(by: disposeBag)
    
    // we want to get the latest results, so I really only care about the first result, since the variable is going to get
    // me osmething i want
    Observable.combineLatest(coords.asObservable(), placemarkName.asObservable())
      .map { $0.0 }
      .subscribe(onNext: { [weak self] coords in
        guard let this = self else { return }
        this.centerLocation(location: CLLocation(latitude: coords.1, longitude: coords.2))
        let annotation = MKPointAnnotation()
        annotation.title = this.placemarkName.value
        annotation.subtitle = coords.0
        annotation.coordinate = CLLocationCoordinate2D(latitude: coords.1, longitude: coords.2)
        
        this.mapView.addAnnotation(annotation)
      })
      .disposed(by: disposeBag)
  }
  
  /**
    Centers the location for us when setting up the region
   **/
  fileprivate func centerLocation(location: CLLocation) {
    // some random constant
    let regionRadius: CLLocationDistance = 1000
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
    mapView.setRegion(coordinateRegion, animated: true)
  }
}

// MARK: MKMapViewDelegate
extension MeetupLocationCell: MKMapViewDelegate {
  // gets the annotation for us
  public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    // if the annotation is the user's location, then we can't do a call out
    if annotation is MKUserLocation { return nil }
    // create an identifier so the next time we do it it'll open for us
    let identifier = "meetup"
    // attempt to see
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
    // check the notifications
    if annotationView == nil {
      annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
      annotationView?.canShowCallout = true
    } else {
      annotationView?.annotation = annotation
    }
    
    return annotationView
  }
}
