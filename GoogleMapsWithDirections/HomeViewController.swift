//
//  HomeViewController.swift
//  GoogleMapsWithDirections
//
//  Created by prasanth.podalakur on 7/19/17.
//  Copyright © 2017 Kelltontech. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces
import SwiftyJSON
import Alamofire

enum Location {
    case startLocation
    case destinationLocation
}
class HomeViewController: UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate,GMSAutocompleteViewControllerDelegate {
    @IBOutlet weak var segmentButton: UISegmentedControl!

    var locationManager = CLLocationManager()
    let didFindMyLocation = false
    var locationSelected = Location.startLocation
    var locationStart = CLLocation()
    var locationEnd = CLLocation()

    @IBOutlet weak var mapView: GMSMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()

       //Location Manager code to fetch current location

        
        let camera = GMSCameraPosition.camera(withLatitude: -7.9293122, longitude: 112.5879156, zoom: 15.0)
        
        self.mapView.camera = camera
        
        self.mapView.delegate = self
        self.mapView?.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true
        self.mapView.settings.compassButton = true
        self.mapView.settings.zoomGestures = true
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        
        self.mapView?.animate(to: camera)
        self.drawPath(startLocation: locationStart, endLocation: locationEnd)
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        
    }
    
    
    // MARK: - GMS Auto Complete Delegate, for autocomplete search location
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error \(error)")
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        // Change map location
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 16.0
        )
        
        // set coordinate to text
        if locationSelected == .startLocation {
            locationStart = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            self.convertingAddress(location: CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude))
            // createMarker(titleMarker: "Location Start \(cityName)", iconMarker: UIImage(named: "StartMark")!, latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        } else {
            locationEnd = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            self.convertingAddress(location:  CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude))
            // createMarker(titleMarker: "Location End  \(cityName)", iconMarker: UIImage(named: "EndMark")!, latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }
        
        
        self.mapView.camera = camera
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    

    
    @IBAction func mapTypeButtonTapped(_ sender: UISegmentedControl) {
        
        switch self.segmentButton.selectedSegmentIndex
        {
        case 0:
           self.mapView.mapType = .normal
        
            break
        case 1:
            self.mapView.mapType = .satellite
            break
        case 2:
           self.mapView.mapType = .hybrid
        default:
            break;
        }
    }
    
    

    // MARK: when start location tap, this will open the search location
    @IBAction func openStartLocation(_ sender: UIButton) {
        self.mapView.clear()
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        // selected location
        locationSelected = .startLocation
        
        // Change text color
        UISearchBar.appearance().setTextColor(color: UIColor.black)
        self.locationManager.stopUpdatingLocation()
        
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    // MARK: when destination location tap, this will open the search location
    @IBAction func openDestinationLocation(_ sender: UIButton) {
        
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        // selected location
        locationSelected = .destinationLocation
        
        // Change text color
        UISearchBar.appearance().setTextColor(color: UIColor.black)
        self.locationManager.stopUpdatingLocation()
        
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    @IBAction func showDirection(_ sender: UIButton) {
        // when button direction tapped, must call drawpath func
       self.drawPath(startLocation: locationStart, endLocation: locationEnd)
    }
    
    // MARK: function for create a marker pin on map
    
    func createMarker(titleMarker: String, iconMarker: UIImage, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = titleMarker
        marker.icon = iconMarker
        marker.map = mapView
    }

    
    //MARK: - this is function for create direction path, from start location to desination location
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving"
        
        Alamofire.request(url).responseJSON { response in
            
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization
            
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            // print route using Polyline
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 5
                polyline.strokeColor = UIColor(red: 23.0/255, green: 163.0/255, blue: 225.0/255, alpha: 1)
                polyline.map = self.mapView
            }
            
        }
    }
    
    
    //MARK:-  converting longitude and latitude coordinates to address? in swift
    
    func convertingAddress(location:CLLocation) {
        let geoCoder = CLGeocoder()
        print("\(location.coordinate.latitude)")
        geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
            guard let addressDict = placemarks?[0].addressDictionary else {
                return
            }
            
            // Print each key-value pair in a new row
            addressDict.forEach { print($0) }
            
            // Print fully formatted address
            if let formattedAddress = addressDict["FormattedAddressLines"] as? [String] {
                print(formattedAddress.joined(separator: ", "))
            }
            
            // Access each element manually
            if let locationName1 = addressDict["Name"] as? String {
                
               
                print(locationName1)
            }
            if self.locationSelected == .startLocation {
                if let locationName = addressDict["SubLocality"] as? String {
                    self.createMarker(titleMarker: "\(locationName)", iconMarker: UIImage(named: "EndMark")!, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                }else{
                    self.createMarker(titleMarker: " Location Start", iconMarker: UIImage(named: "EndMark")!, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                }

                
            }else{
                if let locationName = addressDict["SubLocality"] as? String {
                    self.createMarker(titleMarker: "\(locationName)", iconMarker: UIImage(named: "StartMark")!, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                }else{
                    self.createMarker(titleMarker: " Location Start", iconMarker: UIImage(named: "StartMark")!, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                }

            }
            if let street = addressDict["Thoroughfare"] as? String {
                print(street)
            }
            
            if let city = addressDict["City"] as? String {
                
                print(city)
            }
            if let zip = addressDict["ZIP"] as? String {
                print(zip)
            }
            if let country = addressDict["Country"] as? String {
                print(country)
            }
        })
   
        
    }
    
   }


public extension UISearchBar {
    
    public func setTextColor(color: UIColor) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
    }
    
}
