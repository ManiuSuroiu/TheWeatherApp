//
//  ViewController.swift
//  TheWeatherApp
//
//  Created by wehiremac on 16/09/2017.
//  Copyright © 2017 wehiremac. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController {
  
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var weatherForecastButton: UIButton!
  @IBOutlet weak var getMyLocationButton: UIButton!
  
  let locationManager = CLLocationManager()
  let geocoder = CLGeocoder()
  
  var lastLocation: CLLocation?
  var updatingLocation = false
  var placemark: CLPlacemark?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateLabels()
  }
  
  /* determines the location authorization status and performs a certain action associated with that status */
  @IBAction func getUserLocation() {
    let authStatus = CLLocationManager.authorizationStatus()
    
    switch authStatus {
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
    case .denied, .restricted:
      showLocationServicesDeniedAlert()
    case .authorizedWhenInUse, .authorizedAlways:
      
      if updatingLocation {
        stopLocationManager()
      } else {
        lastLocation = nil
        placemark = nil
        startLocationManager()
      }
    }
  }
  
  func showLocationServicesDeniedAlert() {
    let alert = UIAlertController(title: "Location Services Disabled",
                                  message: "Please enable location services for this app in Settings",
                                  preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
    
    let settingsAction = UIAlertAction(title: "Settings",
                                       style: .default,
                                       handler: { _ in UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!) })
    alert.addAction(settingsAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
  }
  
  /* CLLocationManager into action - this is where it obtains GPS coordinates (by calling the startUpdatingLocation()) */
  func startLocationManager() {
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.startUpdatingLocation()
      updatingLocation = true
    }
  }
  
  func stopLocationManager() {
    if updatingLocation {
      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
      updatingLocation = false
    }
  }
  
  /* once the location manager begins updating user's location, put the latitude and longitude in the format required by the Foursquare API parameter (LatLongCoordinates - Constants.swift). Call this method from the delegate method locationManager(didUpdateLocations:) */
  func formatGPSCoordinates() -> String {
    if let location = lastLocation {
      let latitudeString = String(format: "%.8f", location.coordinate.latitude)
      let longitudeString = String(format: "%.8f", location.coordinate.longitude)
      return latitudeString + "," + longitudeString
    } else {
      return ""
    }
  }
  
  func updateLabels() {
    
    if let location = lastLocation {
      latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
      longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
      weatherForecastButton.isHidden = false
      messageLabel.text = ""
    } else {
      latitudeLabel.text = ""
      longitudeLabel.text = ""
      weatherForecastButton.isHidden = true
      messageLabel.text = "Tap 'Get My Location' to start"
    }
  }
}

// MARK: - CLLocationManagerDelegate

extension CurrentLocationViewController: CLLocationManagerDelegate {
  
  /* tells the delegate that the location manager was unable to retrieve a location value. Uses a switch statemnet to look at the most common reasons that caused the error to occur. Each case creates an alert view controller to show the respective error to the user  */
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    
    switch (error as NSError).code {
      
    case CLError.network.rawValue:
      let alert = UIAlertController(title: "Network Error",
                                    message: "The network is unavailable or a network error occurred",
                                    preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alert.addAction(okAction)
      
    case CLError.locationUnknown.rawValue:
      let alert = UIAlertController(title: "Error Getting Location",
                                    message: "The GPS is unable to obtain your location right now",
                                    preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alert.addAction(okAction)
      present(alert, animated: true, completion: nil)
      
    default:
      let alert = UIAlertController(title: "An Error Has Occurred",
                                    message: "Your location cannot be determined right now",
                                    preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alert.addAction(okAction)
      present(alert, animated: true, completion: nil)
    }
  }
  
  /* tells the delegate that new location data is available while storing it in a [ClLocation] array */
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let newLocation = locations.last!
    print("didUpdateLocations \(newLocation)")
    lastLocation = newLocation
    updateLabels()
  }

}

