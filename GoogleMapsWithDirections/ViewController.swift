//
//  ViewController.swift
//  GoogleMapsWithDirections
//
//  Created by prasanth.podalakur on 7/19/17.
//  Copyright © 2017 Kelltontech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
/*
 
 let camera = GMSCameraPosition.camera(withLatitude: 23.931735,longitude: 121.082711, zoom: 7)
 let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
 
 mapView.isMyLocationEnabled = true
 self.mapView = mapView
 
 // GOOGLE MAPS SDK: BORDER
 let mapInsets = UIEdgeInsets(top: 80.0, left: 0.0, bottom: 45.0, right: 0.0)
 mapView.padding = mapInsets
 
 locationManager.distanceFilter = 100
 locationManager.delegate = self
 locationManager.requestWhenInUseAuthorization()
 
 // GOOGLE MAPS SDK: COMPASS
 mapView.settings.compassButton = true
 
 // GOOGLE MAPS SDK: USER'S LOCATION
 mapView.isMyLocationEnabled = true
 mapView.settings.myLocationButton = true
 
 
 
 
 
 
 
 // MARK: - CLLocationManagerDelegate
 extension HomeViewController: CLLocationManagerDelegate {
 
 private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
 if status == .authorizedWhenInUse {
 locationManager.startUpdatingLocation()
 mapView.isMyLocationEnabled = true
 mapView.settings.myLocationButton = true
 }
 }
 private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
 if let location = locations.first {
 mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 20, bearing: 0, viewingAngle: 0)
 locationManager.stopUpdatingLocation()
 }
 }
 }
 */

