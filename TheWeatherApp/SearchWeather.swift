//
//  SearchWeather.swift
//  TheWeatherApp
//
//  Created by Maniu Suroiu on 17/09/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit
import CoreLocation

class SearchWeather {
  
  var searchResults: [Weather] = []
  var location: CLLocation?
  private var dataTask: URLSessionDataTask?
  
  func performSearch(completion: @escaping (_ success: Bool) -> Void) {
    
    let urlString = "http://api.openweathermap.org/data/2.5/forecast?lat=\(String(describing: location!.coordinate.latitude))&lon=\(String(describing: location!.coordinate.longitude))&appid=4ecdd25eafcd43806646199863ce2906"
    
    let url = URL(string: urlString)
    let request = NSMutableURLRequest(url: url!)
    
    dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
      
      completion(false)
      
      guard (error == nil) else {
        print("There was an error with your request: \(String(describing: error))")
        return
      }
      
      guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 200 else {
        print("Your request returned a status code other than 200")
        return
      }
      
      guard let jsonData = data else {
        print("No data was returned by your request")
        return
      }
      
      if let jsonDictionary = self.parse(json: jsonData) {
        self.searchResults = self.parse(dictionary: jsonDictionary)
        
        DispatchQueue.main.async {
          completion(true)
        }
      }
    }
    dataTask?.resume()
  }
  
  private func parse(json data: Data) -> [String: AnyObject]? {
    do {
      return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
    } catch {
      print("Could not parse the data as JSON: \(data)")
      return nil
    }
  }
  
  private func parse(dictionary: [String: AnyObject]) -> [Weather] {
    
    var search: [Weather] = []
    
    guard let listArray = dictionary["list"] as? [[String: AnyObject]] else {
      print("Could not find key 'list' in: \(dictionary)")
      return search
    }
    
    for dictionary in listArray {
      
      let searchResult = Weather()
      
      if let mainDictionary = dictionary["main"] as? [String: AnyObject],
        let minTemperatureValue = mainDictionary["temp_min"] as? Double,
        let maxTemperatureValue = mainDictionary["temp_max"] as? Double {
        
        searchResult.minTemperature = minTemperatureValue - 273.15
        searchResult.maxTemperature = maxTemperatureValue - 273.15
      }
      
      if let weatherArray = dictionary["weather"] as? [[String: AnyObject]],
        let dict = weatherArray.first,
        let iconCode = dict["icon"] as? String {
        
        searchResult.icon = iconCode
      }
      
      if let dateAndTime = dictionary["dt_txt"] as? String {
        searchResult.dateString = dateAndTime
      }
      search.append(searchResult)
    }
    return search
  }
}






