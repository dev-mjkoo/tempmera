//
//  Image.swift
//  tempmera
//
//  Created by 구민준 on 2021/10/31.
//

import Foundation
import UIKit  

class ImageData {
  var imageName: String
  var imageSaveDate: String
  var imageSaveTime: String
  var imageEndDate: String
  var imageEndTime: String
  var image: UIImage?
  
  init(_ imageName: String, _ imageSaveDate: String, _ imageSaveTime: String, _ imageEndDate: String, _ imageEndTime: String) {
    self.imageName = imageName
    self.imageSaveDate = imageSaveDate
    self.imageSaveTime = imageSaveTime
    self.imageEndDate = imageEndDate
    self.imageEndTime = imageEndTime
  }
  
  init(_ imageName: String) {
    self.imageName = imageName
    
    let nowDate = Date()
    let addDate = nowDate.addingDays(days: 1)
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"
    self.imageSaveDate = dateFormatter.string(from: nowDate)
    self.imageEndDate = dateFormatter.string(from: addDate)
    
    dateFormatter.dateFormat = "HHmmss"
    self.imageSaveTime = dateFormatter.string(from: nowDate)
    self.imageEndTime = dateFormatter.string(from: nowDate)
  }
}
