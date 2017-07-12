//
//  GeolocationViewController.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 30/06/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class GeolocationViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var redoSearchBtn: UIButton!
  
   // var locationManager:CLLocationManager!
    var mRect : MKMapRect!
    var isInitialized: Bool?
    var updateIsInitialized: Bool?
    var didInitialZoom: Bool?
    var isReachable : Bool?
    var newUserLocation : CLLocation?
    var pointLocation : CLLocation?
    let locationService = LocationService.sharedInstance
    
    
    //var friendsLocMockArr = [FriendsLocation]() // Only for mock test
    
    var friends : [User] = []
    
    // Mock for friends locations
    struct FriendsLocation {
        var coord2D : CLLocationCoordinate2D?
        var user : UserMock?
    }

    // Mock for friends locations
    var friendslocations = [FriendsLocation(coord2D: CLLocationCoordinate2D(latitude:48.8990803 , longitude:2.088805), user:UserMock(id:"1", username : "User1") ), FriendsLocation(coord2D:  CLLocationCoordinate2D(latitude:48.8989736 , longitude:2.0894518), user:UserMock(id:"2", username : "User2")), FriendsLocation( coord2D: CLLocationCoordinate2D(latitude:48.9136485 , longitude:2.1117353), user:UserMock(id:"3", username : "User3")), FriendsLocation(coord2D: CLLocationCoordinate2D(latitude:48.8995867 , longitude:2.0935571), user:UserMock(id:"4", username : "User4"))]
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        didInitialZoom = false
        isReachable = false
        updateIsInitialized = false
        pointLocation = locationService.pointFCMLocation
        
        redoSearchBtn.layer.cornerRadius = 15;
        redoSearchBtn.contentEdgeInsets = UIEdgeInsetsMake(5,10,5,10)
        
        
        if let initialLocationStatus = locationService.isReachabled {
            self.isReachable = initialLocationStatus
        }
        
        if let initialUserLocation = locationService.initialLocation {
            
            newUserLocation = initialUserLocation
            
            let region = MKCoordinateRegionMakeWithDistance(initialUserLocation.coordinate, 400, 400)
            self.mapView.setRegion(region, animated: false)
            
            // Set delay to ensure map has been completely loaded
            // before getting friends location on map
            let when = DispatchTime.now() + 3 // for 3 sec
            DispatchQueue.main.asyncAfter(deadline: when) {
                
                self.getFriendsInMapArea()
                
            }

        }
        
        // Register to receive updated user's location
        NotificationCenter.default.addObserver(self, selector: #selector(GeolocationViewController.updateMap(_:)), name: Notification.Name(rawValue:"didUpdateLocation"), object: nil)
        
        // Register to receive updated location service status
        NotificationCenter.default.addObserver(self, selector: #selector(GeolocationViewController.updateLocationService(_:)), name: Notification.Name(rawValue:"didUpdateLocationServiceStatus"), object: nil)
        
        // Register to received FCM Points
        NotificationCenter.default.addObserver(self, selector: #selector(GeolocationViewController.addPointsToMap(_:)), name: Notification.Name(rawValue:"didReceivedFCMPoints"), object: nil)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateLocationService(_ notification: NSNotification) {
        
        print("update location status")
        
        if let userInfo = notification.userInfo{
            
            if let newStatus = userInfo["isReachabled"] as? Bool{
                
                print("location service status = \(newStatus)")
    
                if newStatus == false {
                    
                    cleanMap()
                    updateIsInitialized = false
                    self.locationServiceDisabledAlert(title: "Location services are disabled", message: "Please go to Settings and turn on Location Service for this app.")
                    
                    isReachable = false
                }
                else {
                    isReachable = true
                }
                
            }
            
        }
    }
    
    func addPointsToMap(_ notification: NSNotification) {
        
        print("Received FCM points")
        
        var lat : Double!
        var long : Double!
        var title: String!
        var invalidPoint = false;
    
        
        if let userInfo = notification.userInfo {
            
            
            if let pointTitle = userInfo["title"] as? String{
                
                title = pointTitle
                
                print("receive point latitude  = \(title)")
                
            }else {
            
                invalidPoint = true
            }
            
            if let pointLatitude = userInfo["latitude"] as? String{
                
                lat = Double(pointLatitude)
                
                print("receive point latitude  = \(lat!)")
               
            }else{
            
                invalidPoint = true
            }
            
            if let pointLongitude = userInfo["longitude"] as? String{
                
                long = Double(pointLongitude)
                
                print("receive point latitude  = \(long!)")
                
            }
            else{
                
                invalidPoint = true
            }
            
            
            if !invalidPoint {
                getFCMPointInMapArea(pointLatitude: lat, pointLongitude: long, pointTitle: title)
            }
            
            
        }

    }
    
    func updateMap(_ notification: NSNotification) {
        
        if !updateIsInitialized!{
            
            print("update map")
            
            if let userInfo = notification.userInfo{
                
                if let newLocation = userInfo["userLocation"] as? CLLocation{
                    
                    newUserLocation = newLocation
                    
                    print("user latitude 2 = \(newLocation.coordinate.latitude)")
                    print("user longitude 2 = \(newLocation.coordinate.longitude)")
                    let region = MKCoordinateRegionMakeWithDistance((newUserLocation?.coordinate)!, 400, 400)
                    self.mapView.setRegion(region, animated: false)
                }
            }
            
            self.getFriendsInMapArea()
            
        }
        
        updateIsInitialized = true
    }

    
    @IBAction func refreshlocation(_ sender: Any) {
        
        cleanMap()
        
        if isReachable! {
            
            let region = MKCoordinateRegionMakeWithDistance((newUserLocation?.coordinate)!, 400, 400)
            self.mapView.setRegion(region, animated: false)
            
            // Set delay to ensure map has been completely loaded
            // before getting friends location on map
            
            self.getFriendsInMapArea()
            
        }
        else {
            updateIsInitialized = false
            self.locationServiceDisabledAlert(title: "Location services are disabled", message: "Please go to Settings and turn on Location Service for this app.")
        }
    }
    
    
    @IBAction func redoSearch(_ sender: UIButton) {

        if isReachable! {
            cleanMap()
            getFriendsInMapArea()
        }
        else{
             updateIsInitialized = false
             self.locationServiceDisabledAlert(title: "Location services are disabled", message: "Please go to Settings and turn on Location Service for this app.")
        }
        
    }

}


// Custom Annotations
class FriendsAnnotation: NSObject, MKAnnotation {
    
    let user: User
    let title: String?
    let subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(user: User, coordinate: CLLocationCoordinate2D) {
        self.user = user
        self.title = user.username
        self.subtitle = user.username
        self.coordinate = coordinate
        
        super.init()
    }
}
class FcmAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String?, subtitle: String?,  coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        super.init()
    }
}


// Extension for Map
extension GeolocationViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKUserLocation) {
            
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: String(annotation.hash))
            
            let rightButton = UIButton(type: .contactAdd)
            rightButton.tag = annotation.hash
            print("My tag : ", rightButton.tag)
            
            pinView.animatesDrop = true
            pinView.canShowCallout = true
            pinView.rightCalloutAccessoryView = rightButton
            
            
            return pinView
        }
        else {
            return nil
        }
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
    
        if control == view.rightCalloutAccessoryView {
            print("show details")
            
            let annotaion = view.annotation as? FriendsAnnotation
            followUserAlert(user: (annotaion?.user)!)
            
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        print("Annotation selected")
        
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.blue
        polylineRenderer.lineWidth = 5
 
        return polylineRenderer
    }
    
    func cleanMap() {
        
        // Remove all data stores for annotations
        self.friends.removeAll()
        
        // Remove all locations on the map except user location
        self.mapView.annotations.forEach {
            if !($0 is MKUserLocation) {
                self.mapView.removeAnnotation($0)
            }
        }
        
    }
    
    func showRouteOnMap(points1 : CLLocationCoordinate2D , points2: CLLocationCoordinate2D) {
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: points1, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: points2, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            if (unwrappedResponse.routes.count > 0) {
                self.mapView.add(unwrappedResponse.routes[0].polyline)
                self.mapView.setVisibleMapRect(unwrappedResponse.routes[0].polyline.boundingMapRect, animated: true)
            }
        }
    }

    
    func getFCMPointInMapArea(pointLatitude: Double, pointLongitude: Double, pointTitle: String) {

        
        // Add new annotation for fcm point
        let fcmAnnotation = FcmAnnotation(title: pointTitle, subtitle: "Get free points", coordinate: CLLocationCoordinate2D(latitude: pointLatitude, longitude: pointLongitude))
        mapView.addAnnotation(fcmAnnotation)
    
        // Set maprect to cover to show the two points between fcm location and the user location
        
        if (self.newUserLocation) != nil {
            
            var points : Array = [CLLocationCoordinate2D]()
            points.append(fcmAnnotation.coordinate)
            points.append(self.newUserLocation!.coordinate)
            
            var rect = MKMapRectNull
            
            for p in points {
                let k = MKMapPointForCoordinate(p)
                rect = MKMapRectUnion(rect, MKMapRectMake(k.x, k.y, 0.1, 0.1))
                print("result: x = \(rect.origin.x) y = \(rect.origin.y)")
            }
            
            // Change the current visible portion of map area to see the two points
            mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets.init(top: 40.0, left: 40.0, bottom: 40.0, right: 40.0), animated: true)
            
            showRouteOnMap(points1: points[0], points2: points[1])
        }

    }
    
    func getFriendsInMapArea() {
        
        // Get the area currently displayed by the map view.
        let mapRect = self.mapView.visibleMapRect
        // We need to calculate the corners of the map so we get the points
        // This is the top right Coordinate
        let NECoord = self.getCoordinateFromMapRectanglePoint(x: MKMapRectGetMaxX(mapRect), y: mapRect.origin.y)
        // This is the bottom left Coordinate
        let SWCoord = self.getCoordinateFromMapRectanglePoint(x: mapRect.origin.x, y: MKMapRectGetMaxY(mapRect))
       
        // Search and display friends locations within the bounds of the visible mapview
        // Only two corners (top-right and bottom-left) are useful for covering this area
        self.computeFriendsLocationInMapRect(minRect: SWCoord, maxRect: NECoord)
    }
    
    func getCoordinateFromMapRectanglePoint(x: Double, y: Double) -> CLLocationCoordinate2D {
        
        // Transform points into lat/long values
        let mapPoint = MKMapPointMake(x, y)
        return MKCoordinateForMapPoint(mapPoint)
    }
    
    
    func computeFriendsLocationInMapRect(minRect : CLLocationCoordinate2D, maxRect:CLLocationCoordinate2D)
    {
        // This Method implement the algorithm for searching friends locations in a given map area
        // It should be deported in API part
        let userWB : WBUser = WBUser()
        userWB.searchFriends(minLong: minRect.longitude.description, maxLong:  maxRect.longitude.description, minLat:  minRect.latitude.description, maxLat:  maxRect.latitude.description, accesToken: AuthenticationService.sharedInstance.accessToken!){
            (result: [User]) in
            if(result.count > 0){
                self.friends = result
                for friend in self.friends {
                    if(friend._id != AuthenticationService.sharedInstance.currentUser?._id){
                        let coord2D : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: friend.latitude!, longitude: friend.longitude!)
                        let annotation = FriendsAnnotation(user: friend, coordinate:coord2D  )
                        self.mapView.addAnnotation(annotation)
                    }
                }
                
            }
        }
    }
}
