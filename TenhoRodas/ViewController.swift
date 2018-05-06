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
  let ignoredPoints = [CLLocationCoordinate2D(latitude: -15.811014, longitude: -47.987146
)]
  
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
    addSearchRouteButton()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func directRide(to destination: GMSPlace) {
    let originString = "\(indieWareHouse.latitude),\(indieWareHouse.longitude)"
    
    let destinationString = "\(destination.coordinate.latitude),\(destination.coordinate.longitude)"
    
    Alamofire.request("https://maps.googleapis.com/maps/api/directions/json?origin=\(originString)&destination=\(destinationString)&sensor=true&mode=walking&alternatives=true").responseJSON { (response) in
      
      if let json = response.result.value as? [String: Any] {
        self.mapView.clear()
        let routes = json["routes"] as! NSArray
        
        for route in routes {
          if let routeDict = route as? NSDictionary {
            let polyline = routeDict["overview_polyline"] as! NSDictionary
            let points = polyline["points"] as! String
            
            let path = GMSPath(fromEncodedPath: points)
            self.line = GMSPolyline(path: path)
            self.line.strokeWidth = 4.0
            

            for ignored in self.ignoredPoints {
              if !GMSGeometryIsLocationOnPathTolerance(ignored, path!, false, 5) {
                self.line.strokeColor = .green
              } else {
                self.line.strokeColor = .red
                print("não pode pintar 👨‍✈️")
              }
              self.line.map = self.mapView
            }
          } else {
            print("lol wat 💁🏻‍♀️")
          }
        }
        
        
        let marker = GMSMarker()
        marker.position = destination.coordinate
        marker.title = "Destination"
        marker.snippet = "UCB"
        marker.map = self.mapView
      }
    }
  }
  
  func addSearchRouteButton() {
    let button = UIButton(type: .custom)
    button.frame = CGRect(origin: .zero, size: CGSize(width: 150, height: 100))
    button.setTitle("Search Route", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.backgroundColor = .yellow
    
    self.mapView.addSubview(button)
    
    let margins = self.mapView.layoutMarginsGuide
    
    button.translatesAutoresizingMaskIntoConstraints = false
    button.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.6).isActive = true
    button.heightAnchor.constraint(equalToConstant: 60).isActive = true
    button.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
    button.centerYAnchor.constraint(equalTo: margins.centerYAnchor, constant: -250).isActive = true
    
    button.addTarget(self, action: #selector(searchRoute), for: .touchUpInside)
  }
  
  @objc func searchRoute() {
    let autocompleteController = GMSAutocompleteViewController()
    autocompleteController.delegate = self
    present(autocompleteController, animated: true, completion: nil)
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

extension ViewController: GMSAutocompleteViewControllerDelegate {
  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    
  }
  
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }
  
  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    directRide(to: place)
    dismiss(animated: true, completion: nil)
  }
}


