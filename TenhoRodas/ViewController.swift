//
//  ViewController.swift
//  TenhoRodas
//
//  Created by Miguel Nery on 05/05/18.
//  Copyright © 2018 Miguel Nery. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import GooglePlaces

class ViewController: UIViewController, CLLocationManagerDelegate {
  
  let indieWareHouse = CLLocationCoordinate2D(latitude: -15.7177674, longitude: -47.886888)
  let locationManager = CLLocationManager()
  var mapView: GMSMapView!
  let mapKey = "AIzaSyD1F5N_CVO33hJlbq73xt1Jfjuw4UsLy0o"
  var line: GMSPolyline!
  
  override func loadView() {
    super.loadView()
    
    let camera = GMSCameraPosition.camera(withLatitude: indieWareHouse.latitude, longitude: indieWareHouse.longitude, zoom: 16.0)
    mapView = GMSMapView(frame: .zero)
    mapView.isMyLocationEnabled = true
    mapView.camera = camera
    view = mapView
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    directRide()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func directRide() {
    let originString = "\(indieWareHouse.latitude),\(indieWareHouse.longitude)"
    let destination = "-15.8651602,-48.0298947"
    
    Alamofire.request("https://maps.googleapis.com/maps/api/directions/json?origin=\(originString)&destination=\(destination)&sensor=true&mode=walking&alternatives=true").responseJSON { (response) in
      
      if let json = response.result.value as? [String: Any] {
        
        let routes = json["routes"] as! NSArray
        
        for route in routes {
          if let routeDict = route as? NSDictionary {
            let polyline = routeDict["overview_polyline"] as! NSDictionary
            let points = polyline["points"] as! String
            print(points)
            
            let path = GMSPath(fromEncodedPath: points)
            self.line = GMSPolyline(path: path)
            self.line.map = self.mapView
            self.line.strokeWidth = 4.0
          } else {
            print("lol wat 💁🏻‍♀️")
          }
        }
          
//        let firstRoute = routes[0] as! NSDictionary
        
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -15.8651602,
                                                 longitude: -48.0298947)
        marker.title = "Destination"
        marker.snippet = "UCB"
        marker.map = self.mapView
      }
    }
  }
  
  func centerCamera() {
    guard let location = mapView.myLocation else {
      fatalError("Could not get user location")
    }
    
    mapView.camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: 16.0)
  }
}
