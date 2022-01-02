//
//  CLGeocoder+Rx.swift
//
//  Created by Daniel Tartaglia on 5/7/16.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
// Modified By: Johnny Nguyen
// THank you Daniel for creating a custom protocol For Rx

import RxSwift
import CoreLocation

public extension Reactive where Base == CLGeocoder {
  func reverseGeocodeLocation(location: CLLocation) -> Observable<[CLPlacemark]> {
    return Observable<[CLPlacemark]>.create { observer in
      geocodeHandler(observer: observer, geocode: curry2(self.base.reverseGeocodeLocation, location))
      return Disposables.create { self.base.cancelGeocode() }
    }
  }
}

private func curry2<A, B, C>(_ f: @escaping (A, B) -> C, _ a: A) -> (B) -> C {
  return { b in f(a, b) }
}

private func curry3<A, B, C, D>(_ f: @escaping (A, B, C) -> D, _ a: A, _ b: B) -> (C) -> D {
  return { c in f(a, b, c) }
}

private func geocodeHandler(observer: AnyObserver<[CLPlacemark]>, geocode: @escaping (@escaping CLGeocodeCompletionHandler) -> Void) {
  let semaphore = DispatchSemaphore(value: 0)
  waitForCompletionQueue.async {
    geocode { placemarks, error in
      semaphore.signal()
      if let placemarks = placemarks {
        observer.onNext(placemarks)
        observer.onCompleted()
      }
      else if let error = error {
        observer.onError(error)
      }
      else {
        observer.onError(RxError.unknown)
      }
    }
    _ = semaphore.wait(timeout: .now() + 30)
  }
}

private let waitForCompletionQueue = DispatchQueue(label: "WaitForGeocodeCompletionQueue")
