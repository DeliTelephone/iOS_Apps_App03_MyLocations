   //
   //  Location+CoreDataClass.swift
   //  MyLocations
   //
   //  Created by Nick "Fox" Borer on 02/14/2023.
   //

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject, MKAnnotation
{
   
   class func nextPhotoID() -> Int
   {
      let userDefaults = UserDefaults.standard
      let currentID = userDefaults.integer(forKey: "PhotoID") + 1
      userDefaults.set(currentID, forKey: "PhotoID")
      
      return currentID
   }
   
   public var coordinate: CLLocationCoordinate2D
   {
      return CLLocationCoordinate2DMake(latitude, longitude)
   }

   public var title: String?
   {
      if locationDesription.isEmpty
      {
	 return "(No Description)"
      }
      else
      {
	 return locationDesription
      }
   }

   public var subtitle: String?
   {
      return category
   }
   
   public var hasPhoto: Bool
   {
      return photoID != nil
   }
   
   public var photoURL: URL
   {
      assert(photoID != nil, "No Photo ID connected to this object")
      let fileName = "Photo-\(photoID!.intValue).jpg"
      return applicationDocumentsDirectory.appendingPathComponent(fileName)
   }
   
   public var photoImage: UIImage?
   {
      return UIImage(contentsOfFile: photoURL.path)
   }
   
   func removePhotoFile()
   {
      if hasPhoto
      {
	 do
	 {
	    try FileManager.default.removeItem(at: photoURL)
	 }
	 catch
	 {
	    print("Error removing File \(error)")
	 }
      }
   }
   
}


