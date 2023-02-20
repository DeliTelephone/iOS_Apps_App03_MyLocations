//
//  String+AddText.swift
//  MyLocations
//
//  Created by Nick "Fox" Borer on 02/18/2023.
//

import UIKit
import CoreData
import CoreLocation
import Foundation

extension String{
mutating func add(
   text: String?,
   separatedBy separator: String = "")
{
   if let text = text
   {
      if isEmpty == false
      {
	 self = self + separator
      }
      self = self + text
   }
}
}
