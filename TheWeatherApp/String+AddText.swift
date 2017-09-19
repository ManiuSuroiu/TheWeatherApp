//
//  String+AddText.swift
//  TheWeatherApp
//
//  Created by Maniu Suroiu on 16/09/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

extension String {
  mutating func add(text: String?, separatedBy separator: String = "") {
    if let text = text {
      if !isEmpty {
        self += separator
      }
      self += text
    }
  }
}
