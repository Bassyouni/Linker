//
//  MapVC.swift
//  Linker
//
//  Created by Bassyouni on 8/9/17.
//  Copyright © 2017 Bassyouni. All rights reserved.
//

import UIKit
import MapKit
import Firebase



class MapVC: UIViewController , MKMapViewDelegate , CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var currentLocation :CLLocation!
    var mapHasCenterdOnce = false
    var geoFire : GeoFire!
    var ref: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        ref = Database.database().reference()
        geoFire = GeoFire(firebaseRef: ref)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //self.locationAuthStatus()
        self.centreMapOnLocation(location: currentLocation)

    }
    
    func locationAuthStatus()
    {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse
        {
            mapView.showsUserLocation = true
            currentLocation = locationManager.location
            Location.location.latitude = currentLocation.coordinate.latitude
            Location.location.longitude = currentLocation.coordinate.longitude
            self.setLocationOnFireBase()
            self.openMapsWithCordinates()
        }
        else
        {
            locationManager.requestWhenInUseAuthorization()
            locationAuthStatus()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse
        {
            self.mapView.showsUserLocation = true
        }

    }
    
    func centreMapOnLocation(location: CLLocation)
    {
        let cordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
        self.mapView.setRegion(cordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if let loc = userLocation.location
        {
            if !mapHasCenterdOnce
            {
                centreMapOnLocation(location: loc)
                mapHasCenterdOnce = true
            }
        }
    }
    
    func setLocationOnFireBase()
    {
        geoFire.setLocation(currentLocation, forKey: "OmarAsharf")
    }
    
    func openMapsWithCordinates()
    {
        var place: MKPlacemark!
        if #available(iOS 10.0, *) {
            place = MKPlacemark(coordinate: currentLocation.coordinate)
        } else {
            place = MKPlacemark(coordinate: currentLocation.coordinate, addressDictionary: nil)
        }
        let destination = MKMapItem(placemark: place)
        destination.name = "Freinds Location"
        let regionDistance: CLLocationDistance = 1000
        let regionSpan = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, regionDistance, regionDistance)
        
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey:  NSValue(mkCoordinateSpan: regionSpan.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
        
        MKMapItem.openMaps(with: [destination], launchOptions: options)
    }

    
    
    
    
    
    
    
    
    
    
    
    
    

}
