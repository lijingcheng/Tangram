//
//  Location.swift
//  Tangram
//
//  Created by 李京城 on 2023/1/29.
//  Copyright © 2023 李京城. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa

public enum LocationStatus {
    case unknown, locating, success, failed
}

public class Location: NSObject, CLLocationManagerDelegate {
    public static let shared = Location()

    public let coordinate = BehaviorRelay<CLLocationCoordinate2D?>(value: nil)
    public let locationStatus = BehaviorRelay<LocationStatus>(value: .unknown)

    private var locationManager = CLLocationManager()

    private let disposeBag = DisposeBag()

    private override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        NotificationCenter.default.rx.notification(Notification.Name.Location.needReload).subscribe(onNext: { [weak self] notification in
            self?.startLocating()
        }).disposed(by: disposeBag)
    }

    public func startLocating() {
        guard locationStatus.value != .locating else {
            return
        }
        
        if !CLLocationManager.hasAuthorization {
            locationFailure()
            return
        }
        
        locationStatus.accept(.locating)
        
        locationManager.startUpdatingLocation()
    }
    
    private func locationFailure() {
        locationStatus.accept(LocationStatus.failed)
        
        NotificationCenter.default.post(name: Notification.Name.Location.didFailure, object: nil)
    }

    deinit {
        self.locationManager.stopUpdatingLocation()
    }
}

extension Location {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            App.Data.latitude = location.coordinate.latitude
            App.Data.longitude = location.coordinate.longitude
            
            NotificationCenter.default.post(name: Notification.Name.Location.didSuccess, object: nil, userInfo: nil)
            
            coordinate.accept(location.coordinate)
            locationStatus.accept(.success)
            
            locationManager.stopUpdatingLocation()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationFailure()
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        startLocating()
    }
}
