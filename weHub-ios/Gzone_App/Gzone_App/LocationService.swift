//
//  LoacationService.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 02/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit
import CoreLocation


class LocationService: NSObject, CLLocationManagerDelegate {

    static let sharedInstance = LocationService()
    
    let locationManager: CLLocationManager
    
    let notificationUserLocation = Notification.Name("didUpdateLocation")
    let notificationLocationService = Notification.Name("didUpdateLocationServiceStatus")
    
    var initialLocation : CLLocation?
    var pointFCMLocation : CLLocation?
    var isInitialLocation : Bool?
    var isReachabled : Bool?
    
     private override init() {
        
        locationManager = CLLocationManager()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10.0
        
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
       
        super.init()
        locationManager.delegate = self
        isInitialLocation = false
        isReachabled = true
        
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            // If status has not yet been determied, ask for authorization
           manager.requestWhenInUseAuthorization()
            isReachabled = true
            break
        case .authorizedWhenInUse:
            // If authorized when in use
            manager.startUpdatingLocation()
            isReachabled = true
            break
        case .authorizedAlways:
            // If always authorized
            manager.startUpdatingLocation()
            isReachabled = true
            break
        case .restricted:
            // If restricted by e.g. parental controls. User can't enable Location Services
            isReachabled = false
            manager.stopUpdatingLocation()
            break
        case .denied:
            // If user denied your app access to Location Services, but can grant access from Settings.app
            isReachabled = false
            manager.stopUpdatingLocation()
            break
        default:
            break
        }
        
        let locationReachabilityDict:[String: Bool] = ["isReachabled": isReachabled!]
        
        // Post notification every time user location service status has been updated
        NotificationCenter.default.post(name: notificationLocationService, object: nil, userInfo: locationReachabilityDict)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0] as CLLocation
        let userLocationDict:[String: CLLocation] = ["userLocation": userLocation]
        
        // Store user location in database every 5sec
        //...
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        if !isInitialLocation! {
            initialLocation = userLocation
            isInitialLocation = true
        }
        
        // Post notification every time user location has been updated with user location as userInfo
        NotificationCenter.default.post(name: notificationUserLocation, object: nil, userInfo: userLocationDict)
        
    }
    
    
}

