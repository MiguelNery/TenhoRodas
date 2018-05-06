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
  
  var reportBtn: UIButton!
  let indieWareHouse = CLLocationCoordinate2D(latitude: -15.7177674,
                                              longitude: -47.886888)
  var showMarker: Bool = false
  var latitude: Double!
  var longitude: Double!
  var centerLocation: CLLocationCoordinate2D!
  let locationManager = CLLocationManager()
  var mapView: GMSMapView!
  let mapKey = "AIzaSyD1F5N_CVO33hJlbq73xt1Jfjuw4UsLy0o"
  var line: GMSPolyline!
  var centralMarker = GMSMarker()
  var cancelReportBtn: UIButton!
  var ignoredPoints = [CLLocationCoordinate2D(latitude: -15.811014, longitude: -47.987146
)]
  
  override func loadView() {
    super.loadView()
    
    let camera = GMSCameraPosition.camera(withLatitude: indieWareHouse.latitude, longitude: indieWareHouse.longitude, zoom: 16.0)
    mapView = GMSMapView(frame: .zero)
    mapView.isMyLocationEnabled = true
    mapView.camera = camera
    mapView.delegate = self
    view = mapView
    
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    setReportBtn()
    cancelReport()
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
                break
//                let marker = GMSMarker()
//                marker.position = CLLocationCoordinate2D(latitude: -15.811014,
//                                                         longitude: -47.987146)
//                marker.title = "Destination"
//                marker.snippet = "UCB"
//                marker.map = self.mapView

              }
            }
            self.line.map = self.mapView
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
  
  func setReportBtn() {
    
    reportBtn = UIButton(type: .custom)
    reportBtn.setTitle("Report", for: .normal)
    reportBtn.setTitleColor(UIColor.white, for: .normal)
    reportBtn.backgroundColor = UIColor.blue
    reportBtn.frame = CGRect(x: view.frame.width * 0.8, y: -view.frame.height * 0.8, width: 120, height: 100)
    reportBtn.addTarget(self, action: #selector(pressed(sender:)), for: .touchUpInside)

    self.view.addSubview(reportBtn)
    
    let margins = self.mapView.layoutMarginsGuide
    
    reportBtn.translatesAutoresizingMaskIntoConstraints = false
    reportBtn.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.6).isActive = true
    reportBtn.heightAnchor.constraint(equalToConstant: 100)
    reportBtn.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -100).isActive = true
    reportBtn.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 20).isActive = true
//    reportBtn.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
    
  }
  
  func cancelReport() {
    cancelReportBtn = UIButton(type: .custom)
    cancelReportBtn.setTitle("Cancel", for: .normal)
    cancelReportBtn.setTitleColor(UIColor.white, for: .normal)
    cancelReportBtn.backgroundColor = UIColor.red
    cancelReportBtn.frame = CGRect(x: view.frame.width * 0.8, y: -view.frame.height * 0.8, width: 120, height: 150)
    cancelReportBtn.addTarget(self, action: #selector(pressedCancel), for: .touchUpInside)
    
    
    self.view.addSubview(cancelReportBtn)
    
    let margins = self.mapView.layoutMarginsGuide
    cancelReportBtn.translatesAutoresizingMaskIntoConstraints = false
    
    cancelReportBtn.bottomAnchor.constraint(equalTo: margins.bottomAnchor,
                                         constant: -100).isActive = true
    cancelReportBtn.rightAnchor.constraint(equalTo: margins.rightAnchor,
                                       constant: -20).isActive = true
  }
  
  @objc func pressed(sender: UIButton!) {
    guard showMarker else {
      showMarker = true
      placeMarkerOnCenter(centerMapCoordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
      return
    }
    

    let marker = createMarker(latitude: latitude, longitude: longitude)
    self.ignoredPoints.append(marker.position)
//
//    for locView in self.view.subviews {
//      if locView.isKind(of: UIButton.self){
//        locView.removeFromSuperview()
//      }
//    }

  }

  @objc func pressedCancel() {
    showMarker = false
    centralMarker.map = nil
//    for locView in self.view.subviews {
//      if locView.isKind(of: UIButton.self){
//        locView.removeFromSuperview()
//      }
//    }
  }
  
  func createMarker(latitude: Double, longitude: Double) -> GMSMarker {
    let marker = GMSMarker()
    marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    marker.map = self.mapView
    
    return marker
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


extension ViewController: GMSMapViewDelegate {
  
  
  
  func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
    latitude = mapView.camera.target.latitude
    longitude = mapView.camera.target.longitude
    if showMarker {
      let centerMapCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      self.placeMarkerOnCenter(centerMapCoordinate:centerMapCoordinate)
    }
  }
  
  func placeMarkerOnCenter(centerMapCoordinate:CLLocationCoordinate2D) {
    if centralMarker == nil {
      centralMarker = GMSMarker()
    }
    centralMarker.position = centerMapCoordinate
    centralMarker.map = self.mapView
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

