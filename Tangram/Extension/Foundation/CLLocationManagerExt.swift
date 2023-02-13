//
//  CLLocationManagerExt.swift
//  Tangram
//
//  Created by 李京城 on 2020/12/25.
//  Copyright © 2020 李京城. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationManager {
    /// 定位权限
    public static var hasAuthorization: Bool {
        guard CLLocationManager.locationServicesEnabled() else {
            return false
        }
        
        switch CLLocationManager().authorizationStatus {
        case .restricted:
            return false
        case .denied:
            return false
        default:
            return true
        }
    }
    
    /// 百度坐标转火星坐标（MKMapView 使用的高德地图用的是火星坐标）
    public static func baiduToMars(_ coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let x_pi = Double.pi * 3000.0 / 180.0
        let x = coordinate.longitude - 0.0065, y = coordinate.latitude - 0.006
        let z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi)
        let theta = atan2(y, x) - 0.000003 * cos(x * x_pi)
        
        return CLLocationCoordinate2DMake(z * sin(theta), z * cos(theta))
    }
}
