//
//  Report.swift
//  TenhoRodas
//
//  Created by Geovanni Oliveira de Jesus on 06/05/2018.
//  Copyright © 2018 Miguel Nery. All rights reserved.
//

import Foundation

class Report {
  var latitude: Double
  var longitude: Double
  var reportType: String
  
  init(latitude: Double, longitude: Double, reportType: String) {
    self.latitude = latitude
    self.longitude = longitude
    self.reportType = reportType
  }
}
