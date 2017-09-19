//
//  ViewController.swift
//  TheWeatherApp
//
//  Created by Maniu Suroiu on 16/09/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
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
  var performingReverseGeocoding = false
  
  let searchWeather = SearchWeather()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateLabels()
    configureGetMyLocationButton()
    weatherForecastButton.layer.borderWidth = 1
    weatherForecastButton.layer.cornerRadius = 10
    getMyLocationButton.layer.borderWidth = 1
    getMyLocationButton.layer.cornerRadius = 10
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowCollection" {
      let controller = segue.destination as! ShowTemperatureViewController
      
      searchWeather.performSearch() {
        
        success in
        
        DispatchQueue.main.async {
          controller.activityIndicator.removeFromSuperview()
          controller.searchWeather = self.searchWeather
          controller.collectionView?.reloadData()
        }
      }
    }
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
    updateLabels()
    configureGetMyLocationButton()
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
      
      if let placemark = placemark {
        addressLabel.text = string(from: placemark)
      } else if performingReverseGeocoding {
        addressLabel.text = "Searching for Address..."
      } else {
        addressLabel.text = "Error finding address"
      }
      
    } else {
      latitudeLabel.text = ""
      longitudeLabel.text = ""
      addressLabel.text = ""
      weatherForecastButton.isHidden = true
      
      if updatingLocation {
        messageLabel.text = "Searching..."
      } else {
        messageLabel.text = "Tap 'Get My Location' to start"
      }
    }
  }
  
  func string(from placemark: CLPlacemark) -> String {
    var line1 = ""
    line1.add(text: placemark.subThoroughfare)
    line1.add(text: placemark.thoroughfare, separatedBy: " ")
    
    var line2 = ""
    line2.add(text: placemark.locality)
    line2.add(text: placemark.administrativeArea, separatedBy: " ")
    line2.add(text: placemark.postalCode, separatedBy: " ")
    
    line1.add(text: line2, separatedBy: "\n")
    return line1
  }
  
  func configureGetMyLocationButton() {
    if updatingLocation {
      getMyLocationButton.setTitle("Stop", for: .normal)
    } else {
      getMyLocationButton.setTitle("Get My Location", for: .normal)
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
    
    stopLocationManager()
    updateLabels()
    configureGetMyLocationButton()
  }
  
  /* tells the delegate that new location data is available while storing it in a [ClLocation] array */
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let newLocation = locations.last!
    print("didUpdateLocations \(newLocation)")
    lastLocation = newLocation
    searchWeather.location = newLocation
    
    if !performingReverseGeocoding {
      print("*** Starting to geocode")
      
      performingReverseGeocoding = true
      
      geocoder.reverseGeocodeLocation(newLocation, completionHandler: { placemarks, error in
        print("*** Found placemarks: \(String(describing: placemarks)), error: \(String(describing: error))")
        
        if error == nil, let placemark = placemarks, !placemark.isEmpty {
          self.placemark = placemark.last!
        } else {
          self.placemark = nil
        }
        self.performingReverseGeocoding = false
        self.updateLabels()
      })
    }
  }
}










