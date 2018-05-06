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
import UberRides
import CoreLocation

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
  var rideBtn: RideRequestButton!
  var currentDestination: GMSPlace?
  var ignoredPoints = [CLLocationCoordinate2D(latitude: -15.811014, longitude: -47.987146
)]
  lazy var reportCenterX = reportBtn.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor)
  
  lazy var reportWidth = reportBtn.widthAnchor.constraint(equalToConstant: 366)
  
  lazy var reportHeight = reportBtn.heightAnchor.constraint(equalToConstant: 122)
  
  lazy var markLeading = reportBtn.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: -350)
  
  lazy var markWidth = reportBtn.widthAnchor.constraint(equalToConstant: 208)
  
  lazy var markHeight = reportBtn.heightAnchor.constraint(equalToConstant: 77)
  
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
    self.currentDestination = destination
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
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: ignored.latitude, longitude: ignored.longitude)
                marker.title = "Inacessível"
                marker.icon = #imageLiteral(resourceName: "rampa_nope")
                marker.map = self.mapView
                break
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
//        marker.snippet = "UCB"
        marker.map = self.mapView
      }
    }
  }
  
  func setDropOffLocation(latitude: Double, longitue: Double) {
    setRideBtn()
    let dropoffLocation = CLLocation(latitude: latitude, longitude: longitude)
    let builder = RideParametersBuilder()
    builder.dropoffLocation = dropoffLocation
    builder.dropoffNickname = "Awesome Place"
    rideBtn.rideParameters = builder.build()
  }
  
  func setRideBtn() {
    self.rideBtn = RideRequestButton()
    rideBtn.center = view.center
    self.view.addSubview(rideBtn)
    let margins = self.mapView.layoutMarginsGuide
    rideBtn.translatesAutoresizingMaskIntoConstraints = false
    
    rideBtn.bottomAnchor.constraint(equalTo: margins.bottomAnchor,
                                            constant: -500).isActive = true
    rideBtn.rightAnchor.constraint(equalTo: margins.rightAnchor,
                                           constant: -20).isActive = true
    rideBtn.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
    
    
  }
  
  func setReportBtn() {
    
    reportBtn = UIButton(type: .custom)
    reportBtn.setImage(UIImage(named: "butao-reportar"), for: .normal)
    reportBtn.addTarget(self, action: #selector(pressed(sender:)), for: .touchUpInside)
    reportBtn.contentMode = .scaleAspectFit

    self.view.addSubview(reportBtn)
    
    let margins = self.mapView.layoutMarginsGuide
    
    reportBtn.translatesAutoresizingMaskIntoConstraints = false
    self.reportWidth.isActive = true
    self.reportHeight.isActive = true
    reportBtn.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -30).isActive = true
    self.reportCenterX.isActive = true
  }

  func cancelReport() {
    cancelReportBtn = UIButton(type: .custom)
    cancelReportBtn.setImage(#imageLiteral(resourceName: "botao-check"), for: .normal)
    cancelReportBtn.addTarget(self, action: #selector(pressedCancel), for: .touchUpInside)
    cancelReportBtn.isHidden = true
    
    
    self.view.insertSubview(cancelReportBtn, at: 2)
//    addSubview(cancelReportBtn)
    
    let margins = self.mapView.layoutMarginsGuide
    cancelReportBtn.translatesAutoresizingMaskIntoConstraints = false
    
    cancelReportBtn.widthAnchor.constraint(equalToConstant: 100).isActive = true
    cancelReportBtn.heightAnchor.constraint(equalToConstant: 77).isActive = true
    
    cancelReportBtn.bottomAnchor.constraint(equalTo: margins.bottomAnchor,
                                         constant: -30).isActive = true
    cancelReportBtn.trailingAnchor.constraint(equalTo: margins.trailingAnchor,
                                       constant: -10).isActive = true
  }
  
  @objc func pressed(sender: UIButton!) {
    guard showMarker else {
      showMarker = true
      placeMarkerOnCenter(centerMapCoordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
      reportBtn.setImage(#imageLiteral(resourceName: "botao-marcar"), for: .normal)
      reportCenterX.isActive = false
      reportWidth.isActive = false
      reportHeight.isActive = false
      markLeading.isActive = true
      markWidth.isActive = true
      markHeight.isActive = true
      
      cancelReportBtn.isHidden = false
      return
    }
    

    let marker = createMarker(latitude: latitude, longitude: longitude)
    self.ignoredPoints.append(marker.position)
  }

  @objc func pressedCancel() {
    showMarker = false
    centralMarker.map = nil
    
    cancelReportBtn.isHidden = true
    
    reportBtn.setImage(UIImage(named: "butao-reportar"), for: .normal)
    
    markWidth.isActive = false
    markHeight.isActive = false
    markLeading.isActive = false
    
    reportCenterX.isActive = true
    reportWidth.isActive = true
    reportHeight.isActive = true
  }
  
  func createMarker(latitude: Double, longitude: Double) -> GMSMarker {
    let marker = GMSMarker()
    marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    marker.map = self.mapView
    marker.icon = #imageLiteral(resourceName: "rampa_nope")
    
    if let currentDestination = self.currentDestination {
      directRide(to: currentDestination)
    }
    
    return marker
  }
  
  func addSearchRouteButton() {
    let button = UIButton(type: .custom)
    
    button.setImage(UIImage(named: "butao-where-to-go"), for: .normal)
    
    self.mapView.addSubview(button)
    
    let margins = self.mapView.layoutMarginsGuide
    
    button.translatesAutoresizingMaskIntoConstraints = false
    button.widthAnchor.constraint(equalToConstant: 337.4).isActive = true
    button.heightAnchor.constraint(equalToConstant: 97.6).isActive = true
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
    setDropOffLocation(latitude: place.coordinate.latitude,
                       longitue: place.coordinate.longitude)
    dismiss(animated: true, completion: nil)
  
  }
}

