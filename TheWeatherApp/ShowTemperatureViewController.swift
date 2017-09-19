//
//  ShowTemperatureViewController.swift
//  TheWeatherApp
//
//  Created by Maniu Suroiu on 17/09/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

class ShowTemperatureViewController: UICollectionViewController {
  
  fileprivate let reuseIdentifier = "TemperatureCell"
  fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
  fileprivate let itemsPerRow: CGFloat = 2
  var searchWeather = SearchWeather()
  
  let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(activityIndicator)
    activityIndicator.frame = view.bounds
    activityIndicator.startAnimating()
  }
}

extension ShowTemperatureViewController {
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return searchWeather.searchResults.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TemperatureCell
    cell.backgroundColor = UIColor.gray
    
    let searchResult = searchWeather.searchResults[indexPath.row]
    cell.minTemperature.text = String(searchResult.minTemperature)
    cell.maxTemperature.text = String(searchResult.maxTemperature)
    cell.dateLabel.text = searchResult.dateString
    
    return cell
  }
}

extension ShowTemperatureViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow
    
    return CGSize(width: widthPerItem, height: widthPerItem)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
}








