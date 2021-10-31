//
//  Date.swift
//  tempmera
//
//  Created by 구민준 on 2021/10/31.
//

import Foundation

extension Date {
  func addingDays(days: Int) -> Date {
    return Calendar.current.date(byAdding: .day, value: days, to: self)!
  }
  
  func addingHours(hours: Int) -> Date {
    return Calendar.current.date(byAdding: .hour, value: hours, to: self)!
  }
  
  func addingMinutes(minutes: Int) -> Date {
    return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
  }
}
